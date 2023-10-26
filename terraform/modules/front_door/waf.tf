resource "aws_wafv2_web_acl" "this" {
  #checkov:skip=CKV2_AWS_31:TODO CLDC-2781 setup WAF logging in cloudwatch
  #checkov:skip=CKV_AWS_192: We do use the AWSManagedRulesKnownBadInputsRuleSet as this check recommends, 
  # it looks like checkov can't analyse properly because of the dynamic rule?
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

  dynamic "rule" {
    # Will not be applied for the empty list, i.e. when restrict_by_ip is false
    for_each = var.restrict_by_ip ? [1] : []
    content {
      name     = "ip-allowlist"
      priority = 1

      action {
        block {}
      }

      statement {
        not_statement {
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.allowed_ips.arn
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "waf-restrict-by-ip"
        sampled_requests_enabled   = true
      }
    }
  }

  rule {
    name     = "aws-managed-rules-amazon-ip-reputation-list"
    priority = 2

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
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        rule_action_override {
          # This rule blocks request bodies over 8KB in size, but CORE needs file uploads so we remove this restriction
          # The default maximum request body size that can be inspected when using cloudfront web ACLs is 16KB, so this
          # does limit the effectiveness of the other rules here. The limit can be increased to up to 64KB if necessary
          # at extra cost.
          # More info here: https://docs.aws.amazon.com/waf/latest/developerguide/web-acl-setting-body-inspection-limit.html
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
    priority = 4

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
    priority = 5

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
    priority = 6

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
    priority = 7

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
    name     = "login-ip-rate-limit"
    priority = 8

    action {
      block {
        custom_response {
          response_code = 429
        }
      }
    }

    statement {
      rate_based_statement {
        aggregate_key_type = "IP"
        limit              = 100

        scope_down_statement {
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.waf_rate_limit_urls.arn

            field_to_match {
              uri_path {}
            }

            text_transformation {
              priority = 0
              type     = "URL_DECODE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-login-ip-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "overall-ip-rate-limit"
    priority = 9

    action {
      block {
        custom_response {
          response_code = 429
        }
      }
    }

    statement {
      rate_based_statement {
        aggregate_key_type = "IP"
        limit              = 2000
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-overall-ip-rate-limit"
      sampled_requests_enabled   = true
    }
  }
}

resource "aws_wafv2_regex_pattern_set" "waf_rate_limit_urls" {
  name     = "${var.prefix}-waf-login-url-regex-patterns"
  provider = aws.us-east-1
  scope    = "CLOUDFRONT"

  regular_expression {
    regex_string = "/account/password/new"
  }

  regular_expression {
    regex_string = "/account/password/reset-confirmation"
  }

  regular_expression {
    regex_string = "/account/sign-in"
  }

  regular_expression {
    regex_string = "/account/two-factor-authentication"
  }

  regular_expression {
    regex_string = "/account/two-factor-authentication/resend"
  }
}

resource "aws_wafv2_ip_set" "allowed_ips" {
  provider = aws.us-east-1

  name               = "${var.prefix}-waf-allowed-ip-set"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.include_test_ips ? concat(local.ip_allowlist, local.ip_allowlist_test) : local.ip_allowlist
}