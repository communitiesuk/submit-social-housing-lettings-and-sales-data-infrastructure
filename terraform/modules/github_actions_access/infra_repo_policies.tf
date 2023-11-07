# TODO CLDC-2820: may be able to restrict this to specific files
data "aws_iam_policy_document" "state_bucket_access" {
  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = var.state_bucket_arns
    effect    = "Allow"
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = formatlist("%s/*", var.state_bucket_arns)
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "state_bucket_access" {
  name   = "state-bucket-access"
  policy = data.aws_iam_policy_document.state_bucket_access.json
}

resource "aws_iam_role_policy_attachment" "infra_repo_state_bucket_access" {
  role       = aws_iam_role.repo["infrastructure"].name
  policy_arn = aws_iam_policy.state_bucket_access.arn
}