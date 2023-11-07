# TODO CLDC-2820: may be able to restrict this to specific files
data "aws_iam_policy_document" "state_access" {
  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = var.state_details[*].bucket_arn
    effect    = "Allow"
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = formatlist("%s/*", var.state_details[*].bucket_arn)
    effect    = "Allow"
  }

  statement {
    actions = [
"dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
    ]
    resources = var.state_details[*].lock_table_arn
    effect = "Allow"
  }
}

resource "aws_iam_policy" "state_access" {
  name   = "state-bucket-access"
  policy = data.aws_iam_policy_document.state_access.json
}

resource "aws_iam_role_policy_attachment" "infra_repo_state_access" {
  role       = aws_iam_role.repo["infrastructure"].name
  policy_arn = aws_iam_policy.state_access.arn
}