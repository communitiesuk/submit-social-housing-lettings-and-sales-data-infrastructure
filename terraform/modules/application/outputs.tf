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

output "rds_complete_connection_string_arn" {
  value       = aws_ssm_parameter.complete_database_connection_string.arn
  description = "The arn of the complete database connection string in the parameter store"
  sensitive   = true
}
