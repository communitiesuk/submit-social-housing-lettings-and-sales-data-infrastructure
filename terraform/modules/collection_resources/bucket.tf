#tfsec:ignore:aws-s3-encryption-customer-key: requires public access
#tfsec:ignore:aws-s3-enable-bucket-encryption: requires public access
resource "aws_s3_bucket" "collection_resources" {
  #checkov:skip=CKV2_AWS_6: Public access block is intentionally disabled for this bucket
  #checkov:skip=CKV2_AWS_62: no need for event notifications
  #checkov:skip=CKV_AWS_144: cross region replication is overkill when this is only for data transfer
  #checkov:skip=CKV_AWS_21: versioning not important, each upload creates a new file with a different name (a random UUID)
  bucket = "${var.prefix}-collection-resources"
}

resource "aws_s3_bucket_logging" "access_logging" {
  bucket        = aws_s3_bucket.collection_resources.id
  target_bucket = aws_s3_bucket.collection_resources_access_logs.id
  target_prefix = ""
}

#tfsec:ignore:aws-s3-block-public-acls: Public ACLs are allowed for this bucket
#tfsec:ignore:aws-s3-block-public-policy: Public policies are allowed for this bucket
#tfsec:ignore:aws-s3-ignore-public-acls: Public ACLs are allowed for this bucket
#tfsec:ignore:aws-s3-no-public-buckets: This bucket is intentionally public
resource "aws_s3_bucket_public_access_block" "collection_resources" {
  bucket = aws_s3_bucket.collection_resources.id

  #checkov:skip=CKV_AWS_53: Public ACLs are intentionally allowed for this bucket
  #checkov:skip=CKV_AWS_54: Public policies are intentionally allowed for this bucket
  #checkov:skip=CKV_AWS_55: Public ACLs are intentionally allowed for this bucket
  #checkov:skip=CKV_AWS_56: This bucket is intentionally public
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.collection_resources.id

  #checkov:skip=CKV_AWS_70: Public access block is intentionally disabled for this bucket
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.collection_resources.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "force_ssl" {
  bucket = aws_s3_bucket.collection_resources.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowSSLRequestsOnly",
        Action    = "s3:*",
        Effect    = "Deny",
        Principal = "*",
        Resource = [
          aws_s3_bucket.collection_resources.arn,
          "${aws_s3_bucket.collection_resources.arn}/*"
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

resource "aws_s3_bucket_lifecycle_configuration" "collection_resources" {
  bucket = aws_s3_bucket.collection_resources.id

  rule {
    id = "expire-old-data"

    filter {}

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
    resources = [aws_s3_bucket.collection_resources.arn]
    effect    = "Allow"
  }

  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.collection_resources.arn}/*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "read_write" {
  name        = "${var.prefix}-collection-resources-bucket-read-write"
  description = "Policy that allows read/write access to the collection resources bucket"
  policy      = data.aws_iam_policy_document.read_write.json
}

resource "aws_s3_bucket_versioning" "collection_resources" {
  bucket = aws_s3_bucket.collection_resources.id

  versioning_configuration {
    status = "Enabled"
  }
}
