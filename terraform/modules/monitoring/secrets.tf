resource "aws_secretsmanager_secret" "email" {
  count = var.create_email_subscription ? 1 : 0

  #checkov:skip=CKV2_AWS_57:secret doesn't require automatic rotation
  name       = "MONITORING_EMAIL"
  kms_key_id = aws_kms_key.this[0].arn
}

data "aws_secretsmanager_secret_version" "email" {
  count = var.create_email_subscription ? 1 : 0

  secret_id = aws_secretsmanager_secret.email[0].arn
}
