data "aws_iam_policy_document" "state_access" {
  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [module.tf_state_backend.s3_bucket_arn]
    effect    = "Allow"
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["${module.tf_state_backend.s3_bucket_arn}/*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [module.tf_state_backend.dynamodb_table_arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "state_access" {
  name   = "${local.prefix}-state-access"
  policy = data.aws_iam_policy_document.state_access.json
}