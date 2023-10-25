# TODO: encryption and checkov skips

resource "aws_secretsmanager_secret" "paas_bucket_access_key_id" {
  for_each = var.buckets

  name       = "${var.prefix}-${each.key}-bucket-access-key-id"
  kms_key_id = aws_kms_key.this.arn
}

resource "aws_secretsmanager_secret" "paas_bucket_secret_access_key" {
  for_each = var.buckets

  name       = "${var.prefix}-${each.key}-bucket-secret-access-key"
  kms_key_id = aws_kms_key.this.arn
}