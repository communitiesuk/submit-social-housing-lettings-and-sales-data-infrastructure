module "dead_letter_topic" {
  source = "../monitoring_topic"

  create_email_subscription   = true
  email_subscription_endpoint = var.dead_letter_monitoring_email

  create_lambda_subscription = false

  prefix                                = "${var.prefix}-dead-letter"
  service_identifiers_publishing_to_sns = ["lambda.amazonaws.com"]
}

data "aws_iam_policy_document" "dead_letter_publish" {
  statement {
    actions = [
      "sns:Publish"
    ]
    effect = "Allow"
    resources = [
      module.dead_letter_topic.sns_topic_arn
    ]
  }
}

resource "aws_iam_policy" "dead_letter_publish" {
  name   = "${var.prefix}-lambda-publish-to-dead-letter"
  policy = data.aws_iam_policy_document.dead_letter_publish.json
}

resource "aws_iam_role_policy_attachment" "lambda_publish_to_dead_letter" {
  role       = aws_iam_role.slack_alerts_lambda.name
  policy_arn = aws_iam_policy.dead_letter_publish.arn
}