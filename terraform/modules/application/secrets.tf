resource "aws_secretsmanager_secret" "api_key" {
  name = "API_KEY"
}

resource "aws_secretsmanager_secret" "govuk_notify_api_key" {
  name = "GOVUK_NOTIFY_API_KEY"
}

resource "aws_secretsmanager_secret" "os_data_key" {
  name = "OS_DATA_KEY"
}

resource "aws_secretsmanager_secret" "rails_master_key" {
  name = "RAILS_MASTER_KEY"
}

resource "aws_secretsmanager_secret" "sentry_dsn" {
  name = "SENTRY_DSN"
}
