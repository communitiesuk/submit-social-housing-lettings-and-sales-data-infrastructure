data "aws_iam_policy_document" "cds_assume_role" {
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

data "aws_iam_policy_document" "export_bucket_read_only_access" {
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
  name = "${var.prefix}-export-bucket-read-only-access"
  policy = data.aws_iam_policy_document.export_bucket_read_only_access.json
}
