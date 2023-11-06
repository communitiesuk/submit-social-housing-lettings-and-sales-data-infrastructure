resource "aws_secretsmanager_secret" "email" {
  #checkov:skip=CKV2_AWS_57:secret doesn't require automatic rotation
  name       = "MONITORING_EMAIL"
  kms_key_id = aws_kms_key.this.arn
}

data "aws_secretsmanager_secret_version" "email" {
  count = var.create_secrets_first ? 0 : 1

  secret_id = aws_secretsmanager_secret.email.arn
}
