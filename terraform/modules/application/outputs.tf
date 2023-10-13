output "rds_complete_connection_string_arn" {
  value       = aws_ssm_parameter.complete_database_connection_string.arn
  description = "The arn of the complete database connection string in the parameter store"
  sensitive   = true
}
