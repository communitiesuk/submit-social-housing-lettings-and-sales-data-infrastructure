output "lambda_function_arn" {
  value       = aws_lambda_function.send_slack_alerts.arn
  description = "Lambda function arn"
}