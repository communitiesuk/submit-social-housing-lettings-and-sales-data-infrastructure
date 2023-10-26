resource "aws_secretsmanager_secret" "paas_bucket_access_key_id" {
  #checkov:skip=CKV2_AWS_57: automatic rotation doesn't work here
  for_each = var.buckets

  name       = "${var.prefix}-${each.key}-bucket-access-key-id"
  kms_key_id = aws_kms_key.this.arn
}

resource "aws_secretsmanager_secret" "paas_bucket_secret_access_key" {
  #checkov:skip=CKV2_AWS_57: automatic rotation doesn't work here
  for_each = var.buckets

  name       = "${var.prefix}-${each.key}-bucket-secret-access-key"
  kms_key_id = aws_kms_key.this.arn
}