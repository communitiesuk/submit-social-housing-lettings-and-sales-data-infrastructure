resource "aws_vpc" "this" {
  #checkov:skip=CKV2_AWS_12:we don't think that we should restrict all traffic on the default VPC security group, otherwise our application will be completely isolated
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
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
