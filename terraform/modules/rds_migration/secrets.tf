resource "aws_secretsmanager_secret" "cloudfoundry_password" {
  #checkov:skip=CKV2_AWS_57:secret doesn't require automatic rotation
  kms_key_id = aws_kms_key.this.arn
  name = "CF_PASSWORD"
}

resource "aws_secretsmanager_secret" "cloudfoundry_username" {
  #checkov:skip=CKV2_AWS_57:secret doesn't require automatic rotation
  kms_key_id = aws_kms_key.this.arn
  name = "CF_USERNAME"
}
