resource "aws_iam_role" "cds" {
  name               = "${var.prefix}-cds"
  assume_role_policy = data.aws_iam_policy_document.cds_assume_role.json
}

resource "aws_iam_role_policy_attachment" "cds_export_bucket_access_policy" {
  role       = aws_iam_role.cds.name
  policy_arn = aws_iam_policy.export_bucket_read_only_access.arn
}
