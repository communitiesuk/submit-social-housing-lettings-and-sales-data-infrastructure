resource "aws_vpc" "main" {
  #checkov:skip=CKV2_AWS_12:we don't think that we should restrict all traffic on the default VPC security group, otherwise our application will be completely isolated
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_flow_log" "vpc_accepted" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs_accepted.arn
  traffic_type    = "ACCEPT"
  vpc_id          = aws_vpc.main.id
}

resource "aws_flow_log" "vpc_rejected" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs_rejected.arn
  traffic_type    = "REJECT"
  vpc_id          = aws_vpc.main.id
}

# tfsec:ignore:aws-cloudwatch-log-group-customer-key:flow logs are non-sensitive
resource "aws_cloudwatch_log_group" "vpc_flow_logs_accepted" {
  #checkov:skip=CKV_AWS_158:flow logs are non-sensitive
  #checkov:skip=CKV_AWS_338:we think that a minimum log retention of at least 1 year is excessive and are ok with less
  name              = "${var.prefix}-vpc-flow-logs-accepted"
  retention_in_days = var.vpc_flow_cloudwatch_log_expiration_days
}

# tfsec:ignore:aws-cloudwatch-log-group-customer-key:flow logs are non-sensitive
resource "aws_cloudwatch_log_group" "vpc_flow_logs_rejected" {
  #checkov:skip=CKV_AWS_158:flow logs are non-sensitive
  #checkov:skip=CKV_AWS_338:we think that a minimum log retention of at least 1 year is excessive and are ok with less
  name              = "${var.prefix}-vpc-flow-logs-rejected"
  retention_in_days = var.vpc_flow_cloudwatch_log_expiration_days
}

# https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-cwl.html#flow-logs-iam-role
resource "aws_iam_role" "vpc_flow_logs" {
  name = "${var.prefix}-vpc-flow-logs"

  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_assume_role_permissions.json
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "${var.prefix}-vpc-flow-logs"
  role = aws_iam_role.vpc_flow_logs.id

  policy = data.aws_iam_policy_document.vpc_flow_logs_log_permissions.json
}

# tfsec:ignore:aws-iam-no-policy-wildcards:AWS documentation insists it "must include at least the following permissions" (https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-cwl.html#flow-logs-iam-role)
data "aws_iam_policy_document" "vpc_flow_logs_log_permissions" {
  #checkov:skip=CKV_AWS_111:AWS documentation insists it "must include at least the following permissions" (https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-cwl.html#flow-logs-iam-role)
  #checkov:skip=CKV_AWS_356:AWS documentation insists it "must include at least the following permissions" (https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-cwl.html#flow-logs-iam-role)
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "vpc_flow_logs_assume_role_permissions" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_vpc" "default-eu-west-2" {
  default = true
}

data "aws_vpc" "default-eu-west-1" {
  provider = aws.eu-west-1

  default = true
}

data "aws_vpc" "default-eu-west-3" {
  provider = aws.eu-west-3

  default = true
}

data "aws_vpc" "default-us-east-1" {
  provider = aws.us-east-1

  default = true
}
