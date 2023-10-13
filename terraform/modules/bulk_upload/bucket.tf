#tfsec:ignore:aws-s3-enable-bucket-encryption: default bucket encryption is sufficient
#tfsec:ignore:aws-s3-encryption-customer-key: default encryption is sufficient
#tfsec:ignore:aws-s3-enable-bucket-logging: TODO CLDC-2728
#tfsec:ignore:aws-s3-enable-versioning: Not important, each upload creates a new file with a different name (a random UUID)
resource "aws_s3_bucket" "this" {
  #checkov:skip=CKV2_AWS_62: no need for event notifications
  #checkov:skip=CKV_AWS_18: access logging - TODO CLDC-2728
  #checkov:skip=CKV_AWS_145: default encryption is fine
  #checkov:skip=CKV_AWS_144: cross region replication is overkill when this is only for data transfer
  #checkov:skip=CKV_AWS_21: versioning not important, each upload creates a new file with a different name (a random UUID)
  bucket = "${var.prefix}-bulk-upload"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "force_ssl" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowSSLRequestsOnly",
        Action    = "s3:*",
        Effect    = "Deny",
        Principal = "*",
        Resource = [
          aws_s3_bucket.this.arn,
          "${aws_s3_bucket.this.arn}/*"
        ],
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        },
      },
    ],
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

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
  name        = "${var.prefix}-bulk-upload-bucket-read-write"
  description = "Policy that allows read/write access to the bulk upload bucket"
  policy      = data.aws_iam_policy_document.read_write.json
}