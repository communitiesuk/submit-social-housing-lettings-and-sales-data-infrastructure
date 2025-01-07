data "archive_file" "slack_alerts_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/code"
  output_path = "slack_alerts.zip"
}

#tfsec:ignore:aws-lambda-enable-tracing:Overkill for what this does
resource "aws_lambda_function" "send_slack_alerts" {
  #checkov:skip=CKV_AWS_50:Tracing is overkill for what this does
  #checkov:skip=CKV_AWS_173:Default AWS key is fine for encryption here
  #checkov:skip=CKV_AWS_117:This should be outside our VPC
  #checkov:skip=CKV_AWS_272:Our deployment is sufficiently controlled
  filename      = data.archive_file.slack_alerts_lambda.output_path
  function_name = "${var.prefix}-slack-alerts"
  role          = aws_iam_role.slack_alerts_lambda.arn

  runtime = "ruby3.3"
  handler = "slack_alerts.send_alert"

  source_code_hash = data.archive_file.slack_alerts_lambda.output_base64sha256

  timeout                        = 30
  reserved_concurrent_executions = 50

  dead_letter_config {
    target_arn = module.dead_letter_topic.sns_topic_arn
  }

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
      ENVIRONMENT       = var.environment
    }
  }
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
  name               = "${var.prefix}-slack-alerts-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.slack_alerts_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "with_sns" {
  for_each            = toset(var.monitoring_topics)
  statement_id_prefix = "AllowExecutionFromSNS"
  action              = "lambda:InvokeFunction"
  function_name       = aws_lambda_function.send_slack_alerts.function_name
  principal           = "sns.amazonaws.com"
  source_arn          = each.key
}