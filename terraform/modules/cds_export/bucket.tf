#tfsec:ignore:aws-s3-enable-bucket-encryption: default bucket encryption is sufficient
#tfsec:ignore:aws-s3-encryption-customer-key: default encryption is sufficient
#tfsec:ignore:aws-s3-enable-versioning: Not important, source of data is application db
resource "aws_s3_bucket" "export" {
  #checkov:skip=CKV2_AWS_62: no need for event notifications
  #checkov:skip=CKV_AWS_145: default encryption is fine
  #checkov:skip=CKV_AWS_144: cross region replication is overkill when this is only for data transfer
  #checkov:skip=CKV_AWS_21: versioning not important, data source is elsewhere
  bucket = "${var.prefix}-export${var.bucket_suffix}"
}

resource "aws_s3_bucket_logging" "access_logging" {
  bucket        = aws_s3_bucket.export.id
  target_bucket = aws_s3_bucket.export_access_logs.id
  target_prefix = ""
}

resource "aws_s3_bucket_public_access_block" "export" {
  bucket = aws_s3_bucket.export.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "export" {
  bucket = aws_s3_bucket.export.id

  rule {
    id = "expire-old-data"

    filter {}

    expiration {
      days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    status = "Enabled"
  }
}
