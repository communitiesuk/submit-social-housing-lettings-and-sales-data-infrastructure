#tfsec:ignore:aws-s3-enable-bucket-encryption: default bucket encryption is sufficient
#tfsec:ignore:aws-s3-enable-bucket-logging: access log bucket doesn't need access logging itself
#tfsec:ignore:aws-s3-encryption-customer-key: default encryption is sufficient
#tfsec:ignore:aws-s3-enable-versioning: Not important, each log will be a new file with a different name
resource "aws_s3_bucket" "bulk_upload_access_logs" {
  #checkov:skip=CKV2_AWS_62: no need for event notifications
  #checkov:skip=CKV_AWS_18: access log bucket doesn't need access logging itself
  #checkov:skip=CKV_AWS_145: default encryption is fine
  #checkov:skip=CKV_AWS_144: cross region replication not required for access logs
  #checkov:skip=CKV_AWS_21: versioning not important, each log will be a new file with a different name
  bucket = "${var.prefix}-bulk-upload-logs"
}

resource "aws_s3_bucket_public_access_block" "bulk_upload_access_logs" {
  bucket = aws_s3_bucket.bulk_upload_access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "allow_access_logs" {
  bucket = aws_s3_bucket.bulk_upload_access_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "S3ServerAccessLogsPolicy",
        Action = "s3:PutObject",
        Effect = "Allow",
        Principal = {
          "Service" = "logging.s3.amazonaws.com"
        },
        Resource = [
          "${aws_s3_bucket.bulk_upload_access_logs.arn}/*"
        ],
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.bulk_upload.arn
          },
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "bulk_upload_access_logs" {
  bucket = aws_s3_bucket.bulk_upload_access_logs.id

  rule {
    id = "expire-old-logs"

    filter {}

    expiration {
      days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    status = "Enabled"
  }
}
