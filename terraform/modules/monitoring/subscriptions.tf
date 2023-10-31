resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = data.aws_secretsmanager_secret_version.email.secret_string
}
