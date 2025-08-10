# IAM role and instance profile for CloudWatch
resource "aws_iam_role" "asg_role" {
  name = "asg-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  role       = aws_iam_role.asg_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "asg_profile" {
  name = "asg-cloudwatch-profile"
  role = aws_iam_role.asg_role.name
}

# CloudWatch Log Group for ASG instances
resource "aws_cloudwatch_log_group" "asg_logs" {
  name              = "/aws/asg/instances"
  retention_in_days = 14
}

# CloudWatch Agent configuration
resource "aws_ssm_parameter" "cw_agent" {
  name  = "/cloudwatch-agent/config"
  type  = "String"
  value = jsonencode({
    agent = {
      metrics_collection_interval = 60
      run_as_user               = "root"
    }
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path = "/var/log/syslog"
              log_group_name = "/aws/asg/instances"
              log_stream_name = "{instance_id}"
              timezone = "UTC"
            }
          ]
        }
      }
    }
    metrics = {
      metrics_collected = {
        cpu = {
          measurement = [
            "cpu_usage_idle",
            "cpu_usage_user",
            "cpu_usage_system"
          ]
          metrics_collection_interval = 60
        }
        mem = {
          measurement = [
            "mem_used_percent"
          ]
          metrics_collection_interval = 60
        }
        disk = {
          measurement = [
            "disk_used_percent"
          ]
          metrics_collection_interval = 60
        }
      }
    }
  })
}
