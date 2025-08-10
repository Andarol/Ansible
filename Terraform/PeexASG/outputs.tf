output "asg_name" {
  value = aws_autoscaling_group.asg.name
}

output "step_policy_arn" {
  value = aws_autoscaling_policy.step_scale_up.arn
}

output "simple_policy_arn" {
  value = aws_autoscaling_policy.simple_scale_up.arn
}

output "scheduled_action_name" {
  value = aws_autoscaling_schedule.scheduled_up.scheduled_action_name
}
