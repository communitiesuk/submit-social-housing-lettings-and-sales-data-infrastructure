# TODO CLDC-2779 remove/modify this temporary logging setup
#tfsec:ignore:aws-cloudwatch-log-group-customer-key:TODO CLDC-2779 create and encrypt with a KMS key if retaining this log group
resource "aws_cloudwatch_log_group" "this" {
  #checkov:skip=CKV_AWS_158:TODO CLDC-2779 create and encrypt with a KMS key if retaining this log group
  #checkov:skip=CKV_AWS_338:TODO CLDC-2779 retaining logs for at least 1year greater than necessary for debugging ecs
  name              = "${var.prefix}-db-migration"
  retention_in_days = 60

  tags = {
    Application = var.prefix
  }
}
