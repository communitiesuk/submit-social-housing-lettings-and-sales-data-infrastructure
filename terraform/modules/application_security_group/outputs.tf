output "ecs_security_group_id" {
  value       = aws_security_group.ecs.id
  description = "The id of the ecs security group"
}