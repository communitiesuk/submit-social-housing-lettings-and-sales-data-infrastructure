output "rds_partial_connection_string_parameter_name" {
  value       = aws_ssm_parameter.database_partial_connection_string.name
  description = "The name of the partial database connection string in the parameter store"
}

output "rds_data_access_policy_arn" {
  value       = aws_iam_policy.rds_data_access.arn
  description = "The arn of the iam policy enabling access to the rds data"
}

output "rds_security_group_id" {
  value       = aws_security_group.this.id
  description = "The id of the rds security group"
}
