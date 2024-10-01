output "govuk_notify_api_key_secret_arn" {
  value       = aws_secretsmanager_secret.govuk_notify_api_key.arn
  description = "The arn of the govuk notify api key secret"
}

output "openai_api_key_secret_arn" {
  value       = aws_secretsmanager_secret.openai_api_key.arn
  description = "The arn of the openai api key secret"
}

output "os_data_key_secret_arn" {
  value       = aws_secretsmanager_secret.os_data_key.arn
  description = "The arn of the os data key secret"
}

output "rails_master_key_secret_arn" {
  value       = aws_secretsmanager_secret.rails_master_key.arn
  description = "The arn of the rails master key secret"
}

output "review_app_user_password_secret_arn" {
  value       = aws_secretsmanager_secret.review_app_user_password.arn
  description = "The arn of the rails master key secret"
}

output "sentry_dsn_secret_arn" {
  value       = aws_secretsmanager_secret.sentry_dsn.arn
  description = "The arn of the sentry dsn secret"
}

output "staging_performance_test_email_secret_arn" {
  value       = aws_secretsmanager_secret.staging_performance_test_email.arn
  description = "The arn of the staging performance test email secret"
}

output "staging_performance_test_password_secret_arn" {
  value       = aws_secretsmanager_secret.staging_performance_test_password.arn
  description = "The arn of the staging performance test password secret"
}
