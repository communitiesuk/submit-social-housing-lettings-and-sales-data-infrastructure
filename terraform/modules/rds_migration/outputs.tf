output "db_migration_ecs_security_group_id" {
  value       = aws_security_group.ecs.id
  description = "The id of the db migration ecs security group"
}
