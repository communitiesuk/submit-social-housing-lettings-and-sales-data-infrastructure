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
    }
  }
}
