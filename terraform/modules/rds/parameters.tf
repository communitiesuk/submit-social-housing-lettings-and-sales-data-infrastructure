resource "aws_ssm_parameter" "database_partial_connection_string" {
  #checkov:skip=CKV_AWS_337:default encryption not using a kms cmk sufficient
  name  = "DATABASE_PARTIAL_CONNECTION_STRING"
  type  = "SecureString"
  value = "postgresql://${aws_db_instance.this.username}:${aws_db_instance.this.password}@${aws_db_instance.this.endpoint}"
}
