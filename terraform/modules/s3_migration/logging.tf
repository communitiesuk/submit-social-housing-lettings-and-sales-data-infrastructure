#tfsec:ignore:aws-cloudwatch-log-group-customer-key: Not going to implement this here
resource "aws_cloudwatch_log_group" "this" {
  #checkov:skip=CKV_AWS_158: (also not customer key encrypted)
  #checkov:skip=CKV_AWS_338: These logs don't need long retention
  name              = "${var.prefix}-s3-migration"
  retention_in_days = 90
}