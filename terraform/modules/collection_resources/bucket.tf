#tfsec:ignore:aws-s3-encryption-customer-key: these are public files
#tfsec:ignore:aws-s3-enable-bucket-encryption: these are public files
resource "aws_s3_bucket" "collection_resources" {
  #checkov:skip=CKV2_AWS_62: no need for event notifications
  #checkov:skip=CKV_AWS_144: cross region replication is overkill
  #checkov:skip=CKV_AWS_145: bucket encryption not needed for public files
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

data "aws_iam_policy_document" "force_ssl_policy" {
  statement {
    sid     = "AllowSSLRequestsOnly"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.collection_resources.arn,
      "${aws_s3_bucket.collection_resources.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "force_ssl" {
  bucket = aws_s3_bucket.collection_resources.id

  policy = data.aws_iam_policy_document.force_ssl_policy.json
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
