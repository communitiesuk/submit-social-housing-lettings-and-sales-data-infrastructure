resource "aws_sns_topic_subscription" "email" {
  count = var.create_email_subscription ? 1 : 0

  confirmation_timeout_in_minutes = 30
  topic_arn                       = aws_sns_topic.this.arn
  protocol                        = "email"
  endpoint                        = var.email_subscription_endpoint
}