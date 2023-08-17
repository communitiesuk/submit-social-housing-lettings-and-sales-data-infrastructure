output "rds_security_group_id" {
  value       = aws_security_group.rds.id
  description = "The id of the rds security group"
}

output "rds_data_access_policy_arn" {
  value       = aws_iam_policy.rds-data-acess.arn
  description = "The arn of the iam policy enabling access to the rds data"
}

output "rds_db_connection_string" {
  value       = "postgresql://${aws_db_instance.main.username}:${aws_db_instance.main.password}@${aws_db_instance.main.endpoint}/${aws_db_instance.main.db_name}"
  description = "A libpq (Postgresql) connection string for consuming this database, intended to be set as the environment variable DATABASE_URL"
  sensitive   = true
}
