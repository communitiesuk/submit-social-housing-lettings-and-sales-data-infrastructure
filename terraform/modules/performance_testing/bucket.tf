#tfsec:ignore:aws-s3-enable-versioning: fine without for this purpose
#tfsec:ignore:aws-s3-enable-bucket-logging: fine without for now (see CLDC-3006)
resource "aws_s3_bucket" "results" {
  #checkov:skip=CKV_AWS_144: Don't need cross region replication
  #checkov:skip=CKV_AWS_18: Access logging (see above)
  #checkov:skip=CKV_AWS_21: Versioning (see above)
  #checkov:skip=CKV2_AWS_62: Event notifications, fine without for this purpose
  bucket = "core-performance-testing-results"
}

resource "aws_s3_bucket_public_access_block" "results" {
  bucket = aws_s3_bucket.results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "force_ssl" {
  statement {
    sid       = "AllowSSLRequestsOnly"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.results.arn, "${aws_s3_bucket.results.arn}/*"]
    effect    = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
}

resource "aws_s3_bucket_policy" "force_ssl" {
  bucket = aws_s3_bucket.results.id
  policy = data.aws_iam_policy_document.force_ssl.json
}

resource "aws_s3_bucket_lifecycle_configuration" "results" {
  bucket = aws_s3_bucket.results.id

  rule {
    id = "expire-old-data"

    filter {}

    expiration {
      days = 365
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.results.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}
