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
