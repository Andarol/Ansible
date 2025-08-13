# Create SSH key pair
resource "aws_key_pair" "asg_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_launch_template" "asg_lt" {
  name_prefix   = "asg-demo-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  # Spot instance to reduce cost
  instance_market_options {
    market_type = "spot"
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.asg_sg.id]
  }
}

resource "aws_security_group" "asg_sg" {
  name        = "asg-demo-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.asg_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "asg-demo"
  max_size                  = 5
  min_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = [aws_subnet.private.id]
  launch_template {
    id      = aws_launch_template.asg_lt.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "asg-demo-instance"
    propagate_at_launch = true
  }
}

# Step scaling policy: can add 2 instances at once
resource "aws_autoscaling_policy" "step_scale_up" {
  name                   = "step-scale-up"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "StepScaling"
  adjustment_type        = "ChangeInCapacity"
  metric_aggregation_type = "Average"
  step_adjustment {
    scaling_adjustment = 2
    metric_interval_lower_bound = 0
  }
}
# CloudWatch alarm for CPUUtilization >= 70%
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "asg-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Scale up when average CPU >= 70% for 2 minutes"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  alarm_actions        = [aws_autoscaling_policy.step_scale_up.arn]
}

# Simple scaling policy: adds 1 instance per event
resource "aws_autoscaling_policy" "simple_scale_up" {
  name                   = "simple-scale-up"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown              = 300
}

resource "aws_autoscaling_policy" "target_tracking_policy" {
  name                   = "target-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type           = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_threshold
  }
}

# Scheduled action: scale up at a specific time
resource "aws_autoscaling_schedule" "scheduled_up" {
  scheduled_action_name  = "scheduled-scale-up"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  min_size               = 2
  max_size               = 5
  desired_capacity       = 2
  start_time             = var.scheduled_time
}
