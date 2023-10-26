resource "aws_secretsmanager_secret" "cloudfoundry_password" {
  #checkov:skip=CKV2_AWS_57:secret doesn't require automatic rotation
  name       = "CF_PASSWORD"
  kms_key_id = aws_kms_key.this.arn
}

resource "aws_secretsmanager_secret" "cloudfoundry_username" {
  #checkov:skip=CKV2_AWS_57:secret doesn't require automatic rotation
  name       = "CF_USERNAME"
  kms_key_id = aws_kms_key.this.arn
}
