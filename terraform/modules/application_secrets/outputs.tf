output "govuk_notify_api_key_secret_arn" {
  value       = aws_secretsmanager_secret.govuk_notify_api_key.arn
  description = "The arn of the govuk notify api key secret"
}

output "os_data_key_secret_arn" {
  value       = aws_secretsmanager_secret.os_data_key.arn
  description = "The arn of the os data key secret"
}

output "rails_master_key_secret_arn" {
  value       = aws_secretsmanager_secret.rails_master_key.arn
  description = "The arn of the rails master key secret"
}

output "sentry_dsn_secret_arn" {
  value       = aws_secretsmanager_secret.sentry_dsn.arn
  description = "The arn of the sentry dsn secret"
}

output "openai_api_key_secret_arn" {
  value       = aws_secretsmanager_secret.openai_api_key.arn
  description = "The arn of the openai api key secret"
}
