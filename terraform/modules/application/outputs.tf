output "app_service_name" {
  value       = aws_ecs_service.app.name
  description = "The name of the app service"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "The name of the ecs cluster"
}

output "ecs_security_group_id" {
  value       = aws_security_group.ecs.id
  description = "The id of the ecs security group"
}
