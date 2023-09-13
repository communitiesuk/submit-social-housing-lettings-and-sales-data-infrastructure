locals {
  create_cds_role = var.cds_access_role_arn != null
}

data "aws_iam_policy_document" "cds_assume_role" {
  count = local.create_cds_role ? 1 : 0

  statement {
    actions = [
      "sts:AssumeRole"
    ]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.cds_access_role_arn]
    }
  }
}

resource "aws_iam_role" "cds" {
  count = local.create_cds_role ? 1 : 0

  name               = "${var.prefix}-cds"
  assume_role_policy = data.aws_iam_policy_document.cds_assume_role[0].json
}

#tfsec:ignore:aws-iam-no-policy-wildcards:wildcard required to allow access to all files at the root of the bucket
data "aws_iam_policy_document" "export_bucket_read_only_access" {
  count = local.create_cds_role ? 1 : 0

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.this.arn]
    effect    = "Allow"
  }

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "export_bucket_read_only_access" {
  count = local.create_cds_role ? 1 : 0

  name   = "${var.prefix}-export-bucket-read-only-access"
  policy = data.aws_iam_policy_document.export_bucket_read_only_access[0].json
}

resource "aws_iam_role_policy_attachment" "export_bucket_read_only_access" {
  count = local.create_cds_role ? 1 : 0

  role       = aws_iam_role.cds[0].name
  policy_arn = aws_iam_policy.export_bucket_read_only_access[0].arn
}
