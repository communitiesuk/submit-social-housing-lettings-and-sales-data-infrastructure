#tfsec:ignore:aws-s3-enable-bucket-encryption: default bucket encryption is sufficient for now
#tfsec:ignore:aws-s3-encryption-customer-key: default encryption is sufficient for now
#tfsec:ignore:aws-s3-enable-bucket-logging: TODO
#tfsec:ignore:aws-s3-enable-versioning: Not important, source of data is application db
resource "aws_s3_bucket" "this" {
  #checkov:skip=CKV2_AWS_62: no need for event notifications
  #checkov:skip=CKV_AWS_18: access logging - TODO
  #checkov:skip=CKV_AWS_145: default encryption is fine for now
  #checkov:skip=CKV_AWS_144: cross region replication is overkill when this is only for data transfer
  #checkov:skip=CKV2_AWS_61: lifecycle configuration - TODO
  #checkov:skip=CKV_AWS_21: versioning not important for this
  bucket = "${var.prefix}-export-bucket"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#tfsec:ignore:aws-iam-no-policy-wildcards: require access to all objects in bucket
data "aws_iam_policy_document" "read_write" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.this.arn]
    effect    = "Allow"
  }

  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "read_write" {
  name        = "${var.prefix}-export-bucket-read-write"
  description = "Policy that allows read/write access to the export bucket"
  policy      = data.aws_iam_policy_document.read_write.json
}