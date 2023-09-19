output "rds_security_group_id" {
  value       = aws_security_group.this.id
  description = "The id of the rds security group"
}

output "rds_data_access_policy_arn" {
  value       = aws_iam_policy.rds_data_access.arn
  description = "The arn of the iam policy enabling access to the rds data"
}

output "rds_connection_string_arn" {
  value       = aws_ssm_parameter.database_connection_string.arn
  description = "The arn of the database connection string in the parameter store"
  sensitive   = true
}

output "rds_id" {
  value       = aws_db_instance.this.id
  description = "The id of the rds database"
}
