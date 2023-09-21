output "sns_topic_arn" {
  value       = aws_sns_topic.this.arn
  description = "The arn of the sns topic"
}
