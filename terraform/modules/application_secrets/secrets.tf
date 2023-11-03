resource "aws_secretsmanager_secret" "govuk_notify_api_key" {
  #checkov:skip=CKV2_AWS_57:secret is fixed, can't be automatically rotated
  name       = "GOVUK_NOTIFY_API_KEY"
  kms_key_id = aws_kms_key.this.arn
}

resource "aws_secretsmanager_secret" "os_data_key" {
  #checkov:skip=CKV2_AWS_57:secret is fixed, can't be automatically rotated
  name       = "OS_DATA_KEY"
  kms_key_id = aws_kms_key.this.arn
}

resource "aws_secretsmanager_secret" "rails_master_key" {
  #checkov:skip=CKV2_AWS_57:secret doesn't require automatic rotation
  name       = "RAILS_MASTER_KEY"
  kms_key_id = aws_kms_key.this.arn
}

resource "aws_secretsmanager_secret" "sentry_dsn" {
  #checkov:skip=CKV2_AWS_57:secret is fixed, can't be automatically rotated
  name       = "SENTRY_DSN"
  kms_key_id = aws_kms_key.this.arn
}
