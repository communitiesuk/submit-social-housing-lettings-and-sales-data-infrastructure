data "archive_file" "slack_alerts_lambda" {
  count = var.create_lambda_slack_subscription ? 1 : 0

  type        = "zip"
  source_dir  = "${path.module}/code"
  output_path = "slack_alerts.zip"
}

resource "aws_lambda_function" "send_slack_alerts" {
  count = var.create_lambda_slack_subscription ? 1 : 0

  filename      = data.archive_file.slack_alerts_lambda[0].output_path
  function_name = "${var.prefix}-slack-alerts-${aws_sns_topic.this.name}"
  role          = aws_iam_role.slack_alerts_lambda[0].arn

  runtime = "ruby3.3"
  handler = "slack_alerts.send_alert"

  source_code_hash = data.archive_file.slack_alerts_lambda.output_base64sha256

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
      ENVIRONMENT       = var.environment
    }
  }
}

resource "aws_sns_topic_subscription" "trigger_lambda" {
  count = var.create_lambda_slack_subscription ? 1 : 0

  topic_arn = aws_sns_topic.this.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.send_slack_alerts.arn
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "slack_alerts_lambda" {
  count = var.create_lambda_slack_subscription ? 1 : 0

  name               = "${var.prefix}-slack-alerts-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_execution" {
  count = var.create_lambda_slack_subscription ? 1 : 0

  role       = aws_iam_role.slack_alerts_lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "with_sns" {
  count = var.create_lambda_slack_subscription ? 1 : 0

  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send_slack_alerts.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.this.arn
}