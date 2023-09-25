output "ecs_security_group_id" {
  value       = aws_security_group.ecs.id
  description = "The id of the ecs security group"
}

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

output "sidekiq_service_name" {
  value       = aws_ecs_service.sidekiq.name
  description = "The name of the sidekiq service"
}
