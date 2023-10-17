data "aws_ssm_parameter" "partial_database_connection_string" {
  name = var.database_partial_connection_string_parameter_name
}

resource "aws_ssm_parameter" "complete_database_connection_string" {
  key_id = aws_kms_key.this.arn
  name  = "${upper(var.prefix)}_COMPLETE_DATABASE_CONNECTION_STRING"
  type  = "SecureString"
  value = "${data.aws_ssm_parameter.partial_database_connection_string.value}/${var.database_name}"
}
