resource "aws_sns_topic_policy" "this" {
  arn = aws_sns_topic.this.arn

  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "SNS:Publish"
    ]

    effect = "Allow"

    resources = [
      aws_sns_topic.this.arn
    ]

    principals {
      type        = "Service"
      identifiers = [var.service_identifier_publishing_to_sns]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

data "aws_caller_identity" "current" {}
