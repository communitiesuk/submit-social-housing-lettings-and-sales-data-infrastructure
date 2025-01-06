output "email_for_subscriptions" {
  value       = one(data.aws_secretsmanager_secret_version.email[*].secret_string)
  description = "Email to be used for monitoring subscriptions, from value set in AWS"
}

output "slack_webhook_for_subscriptions" {
  value = one(data.aws_secretsmanager_secret_version.slack_webhook[*].secret_string)
  description = "Slack webhook to be used for monitoring, from value set in AWS"
}
