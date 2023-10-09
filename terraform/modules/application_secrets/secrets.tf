#tfsec:ignore:aws-ssm-secret-use-customer-key:default encryption key is sufficient
resource "aws_secretsmanager_secret" "api_key" {
  #checkov:skip=CKV_AWS_149:default encryption key is sufficient
  #checkov:skip=CKV2_AWS_57:secret doesn't require automatic rotation
  name = "API_KEY"
}

#tfsec:ignore:aws-ssm-secret-use-customer-key:default encryption key is sufficient
resource "aws_secretsmanager_secret" "govuk_notify_api_key" {
  #checkov:skip=CKV_AWS_149:default encryption key is sufficient
  #checkov:skip=CKV2_AWS_57:secret is fixed, can't be automatically rotated
  name = "GOVUK_NOTIFY_API_KEY"
}

#tfsec:ignore:aws-ssm-secret-use-customer-key:default encryption key is sufficient
resource "aws_secretsmanager_secret" "os_data_key" {
  #checkov:skip=CKV_AWS_149:default encryption key is sufficient
  #checkov:skip=CKV2_AWS_57:secret is fixed, can't be automatically rotated
  name = "OS_DATA_KEY"
}

#tfsec:ignore:aws-ssm-secret-use-customer-key:default encryption key is sufficient
resource "aws_secretsmanager_secret" "rails_master_key" {
  #checkov:skip=CKV_AWS_149:default encryption key is sufficient
  #checkov:skip=CKV2_AWS_57:secret doesn't require automatic rotation
  name = "RAILS_MASTER_KEY"
}

#tfsec:ignore:aws-ssm-secret-use-customer-key:default encryption key is sufficient
resource "aws_secretsmanager_secret" "sentry_dsn" {
  #checkov:skip=CKV_AWS_149:default encryption key is sufficient
  #checkov:skip=CKV2_AWS_57:secret is fixed, can't be automatically rotated
  name = "SENTRY_DSN"
}