data "aws_ssm_parameter" "partial_database_connection_string" {
  name = var.database_partial_connection_string_arn
}

resource "aws_ssm_parameter" "complete_database_connection_string" {
  #checkov:skip=CKV_AWS_337:default encryption not using a kms cmk sufficient
  name  = "${var.prefix}_COMPLETE_DATABASE_CONNECTION_STRING"
  type  = "SecureString"
  value = "${data.aws_ssm_parameter.partial_database_connection_string.value}/${var.database_name}"
}
