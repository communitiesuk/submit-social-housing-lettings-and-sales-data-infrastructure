resource "aws_ssm_parameter" "database_partial_connection_string" {
  key_id = aws_kms_key.this.arn
  name  = "DATABASE_PARTIAL_CONNECTION_STRING"
  type  = "SecureString"
  value = "postgresql://${aws_db_instance.this.username}:${aws_db_instance.this.password}@${aws_db_instance.this.endpoint}"
}
