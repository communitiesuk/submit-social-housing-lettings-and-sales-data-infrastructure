#tfsec:ignore:aws-s3-enable-versioning: Not important, each upload creates a new file with a different name (a random UUID)
resource "aws_s3_bucket" "collection_resources" {
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

resource "aws_s3_bucket_public_access_block" "collection_resources" {
  bucket = aws_s3_bucket.collection_resources.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.collection_resources.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
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

  statement {
    actions   = ["kms:GenerateDataKey", "kms:Decrypt"]
    resources = [aws_kms_key.this.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "read_write" {
  name        = "${var.prefix}-collection-resources-bucket-read-write"
  description = "Policy that allows read/write access to the collection resources bucket"
  policy      = data.aws_iam_policy_document.read_write.json
}