terraform {
  required_version = "~>1.5.1"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~>5.0"
      configuration_aliases = [aws.us-east-1]
    }
    random = {
      version = "~>3.5"
      source  = "hashicorp/random"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  bucket_names = {
    cloudfront_logs = contains(var.append_suffix_to_bucket_names, "cloudfront-logs") ? "${var.prefix}-cloudfront-logs-${data.aws_caller_identity.current.account_id}" : "${var.prefix}-cloudfront-logs"
    load_balancer_logs = contains(var.append_suffix_to_bucket_names, "load-balancer-logs") ? "${var.prefix}-load-balancer-logs-${data.aws_caller_identity.current.account_id}" : "${var.prefix}-load-balancer-logs"
  }
}
