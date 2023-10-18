resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.prefix}-s3-migration"
  retention_in_days = 90
}