resource "aws_secretsmanager_secret" "cloudfoundry_password" {
  #checkov:skip=CKV_AWS_149:default encryption key is sufficient
  #checkov:skip=CKV2_AWS_57:secret doesn't require automatic rotation
  name = "CF_PASSWORD"
}

resource "aws_secretsmanager_secret" "cloudfoundry_username" {
  #checkov:skip=CKV_AWS_149:default encryption key is sufficient
  #checkov:skip=CKV2_AWS_57:secret doesn't require automatic rotation
  name = "CF_USERNAME"
}
