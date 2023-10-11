output "ecs_task_execution_role_arn" {
  value       = aws_iam_role.task_execution.arn
  description = "The arn of the ecs task execution role"
}

output "ecs_task_execution_role_name" {
  value       = aws_iam_role.task_execution.name
  description = "The id of the ecs task execution role"
}

output "ecs_task_role_arn" {
  value       = aws_iam_role.task.arn
  description = "The arn of the ecs task role"
}

output "load_balancer_target_group_arn_suffix" {
  value       = aws_lb_target_group.this.arn_suffix
  description = "The arn suffix of the load balancer target group"
}
