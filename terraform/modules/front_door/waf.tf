resource "aws_wafv2_web_acl" "this" {
  #checkov:skip=CKV2_AWS_31:TODO CLDC-2781 setup WAF logging in cloudwatch
  name        = var.prefix
  description = "Web ACL to restrict traffic to CloudFront"
  provider    = aws.us-east-1
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "waf"
    sampled_requests_enabled   = false
  }

  rule {
    name     = "aws-managed-rules-amazon-ip-reputation-list"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-block-disreputable-ip"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-managed-rules-common-rule-set"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        rule_action_override {
          name = "SizeRestrictions_BODY"
          action_to_use {
            allow {}
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-block-common-exploit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-managed-rules-known-bad-inputs-rule-set"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-block-bad-input-exploit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-managed-rules-sqli-rule-set"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-block-sql-exploit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-managed-rules-linux-rule-set"
    priority = 5

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-block-linux-exploit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-managed-rules-unix-rule-set"
    priority = 6

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesUnixRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-block-unix-exploit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "rate-limiting"
    priority = 7

    action {
      block {}
    }

    statement {
      rate_based_statement {
        aggregate_key_type = "IP"
        limit              = 1000
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-rate-limit"
      sampled_requests_enabled   = true
    }
  }
}