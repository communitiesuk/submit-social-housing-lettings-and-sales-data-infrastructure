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
  assume_role_policy = data.aws_iam_policy_document.cds_assume_role.json
}

#tfsec:ignore:aws-iam-no-policy-wildcards:wildcard required to allow access to all files at the root of the bucket
data "aws_iam_policy_document" "export_bucket_read_only_access" {
  count = local.create_cds_role ? 1 : 0

  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Describe*"
    ]

    effect = "Allow"

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "export_bucket_read_only_access" {
  count = local.create_cds_role ? 1 : 0

  name   = "${var.prefix}-export-bucket-read-only-access"
  policy = data.aws_iam_policy_document.export_bucket_read_only_access.json
}

resource "aws_iam_role_policy_attachment" "export_bucket_read_only_access" {
  count = local.create_cds_role ? 1 : 0

  role       = aws_iam_role.cds.name
  policy_arn = aws_iam_policy.export_bucket_read_only_access.arn
}
