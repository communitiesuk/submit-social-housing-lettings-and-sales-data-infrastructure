resource "aws_sns_topic_subscription" "email" {
  count = var.create_secrets_first ? 0 : 1

  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = data.aws_secretsmanager_secret_version.email[0].secret_string
}
