#tfsec:ignore:aws-s3-enable-bucket-encryption: access log buckets not compatible with kms encryption, see https://docs.aws.amazon.com/AmazonS3/latest/userguide/troubleshooting-server-access-logging.html
#tfsec:ignore:aws-s3-enable-bucket-logging: access log bucket doesn't need access logging itself
#tfsec:ignore:aws-s3-encryption-customer-key: access log buckets not compatible with kms encryption, see https://docs.aws.amazon.com/AmazonS3/latest/userguide/troubleshooting-server-access-logging.html
resource "aws_s3_bucket" "cloudfront_access_logs" {
  #checkov:skip=CKV2_AWS_62: no need for event notifications
  #checkov:skip=CKV_AWS_18: access log bucket doesn't need access logging itself
  #checkov:skip=CKV_AWS_145: access log buckets not compatible with kms encryption, see https://docs.aws.amazon.com/AmazonS3/latest/userguide/troubleshooting-server-access-logging.html
  #checkov:skip=CKV_AWS_144: cross region replication not required for access logs
  bucket = "${var.prefix}-cloudfront-logs"
}

resource "aws_s3_bucket_public_access_block" "cloudfront_access_logs" {
  bucket = aws_s3_bucket.cloudfront_access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_access_logs" {
  bucket = aws_s3_bucket.cloudfront_access_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "cloudfront_access_logs" {
  bucket = aws_s3_bucket.cloudfront_access_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowSSLRequestsOnly",
        Action    = "s3:*",
        Effect    = "Deny",
        Principal = "*",
        Resource = [
          aws_s3_bucket.cloudfront_access_logs.arn,
          "${aws_s3_bucket.cloudfront_access_logs.arn}/*"
        ],
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        },
        Sid    = "AllowCloudFrontAccessLogs",
        Action = "s3:PutObject",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Resource = [
          "${aws_s3_bucket.cloudfront_access_logs.arn}/*"
        ],
        Condition = {
          StringEquals = {
            "aws:SourceArn" = aws_cloudfront_distribution.this.arn
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_versioning" "cloudfront_access_logs" {
  bucket = aws_s3_bucket.cloudfront_access_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudfront_access_logs" {
  bucket = aws_s3_bucket.cloudfront_access_logs.id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    expiration {
      days = 90
    }

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }
}