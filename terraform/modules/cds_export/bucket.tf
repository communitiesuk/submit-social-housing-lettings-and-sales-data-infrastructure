#tfsec:ignore:aws-s3-enable-bucket-logging: TODO CLDC-2720
#tfsec:ignore:aws-s3-enable-versioning: Not important, source of data is application db
resource "aws_s3_bucket" "export" {
  #checkov:skip=CKV2_AWS_62: no need for event notifications
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

resource "aws_s3_bucket_policy" "force_ssl" {
  bucket = aws_s3_bucket.export.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowSSLRequestsOnly",
        Action    = "s3:*",
        Effect    = "Deny",
        Principal = "*",
        Resource = [
          aws_s3_bucket.export.arn,
          "${aws_s3_bucket.export.arn}/*"
        ],
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
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

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.export.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}
