locals {
  origin_id              = "${var.prefix}-origin"
  cloudfront_header_name = "X-CLOUDFRONT-HEADER"
}

#tfsec:ignore:aws-cloudfront-enable-logging:TODO we will be implementing logging later
resource "aws_cloudfront_distribution" "this" {
  #checkov:skip=CKV2_AWS_46:false flag, the cloudfront distribution is not serving content from an S3 bucket as the origin, the bucket is only for storing access logs. An s3 origin config is not required
  #checkov:skip=CKV2_AWS_47:The checkov Log4j vulnerability guidance (see link below) suggests implementing the AWSManagedRulesAnonymousIpList and AWSManagedRulesKnownBadInputsRuleSet WAF rules,
  #however AWSManagedRulesAnonymousIpList may cause issues for local authorities / housing associations that use VPNs, and we already implement the other rule
  #https://docs.bridgecrew.io/docs/ensure-aws-cloudfront-attached-wafv2-webacl-is-configured-with-amr-for-log4j-vulnerability
  #checkov:skip=CKV_AWS_86:TODO we will be implementing logging later
  #checkov:skip=CKV_AWS_305:no need to define a default root object because the root of our distribution is just the app's homepage
  #checkov:skip=CKV_AWS_310:we have decided that we're unlikely to need a secondary load balancer
  aliases         = var.initial_create ? [] : [var.cloudfront_domain_name, var.cloudfront_additional_domain_name]
  enabled         = true
  http_version    = "http2and3"
  is_ipv6_enabled = true
  price_class     = "PriceClass_100" # Affects which edge locations are used by cloudfront, which affects the latency users will experience in different geographic areas
  web_acl_id      = aws_wafv2_web_acl.this.arn

  origin {
    domain_name = var.initial_create ? aws_lb.this.dns_name : var.load_balancer_domain_name
    origin_id   = local.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = var.initial_create ? "http-only" : "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = local.cloudfront_header_name
      value = random_password.cloudfront_header.result
    }
  }

  default_cache_behavior {
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id            = aws_cloudfront_cache_policy.this.id
    compress                   = true
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.this.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.this.id
    target_origin_id           = local.origin_id
    viewer_protocol_policy     = "redirect-to-https"
  }

  viewer_certificate {
    cloudfront_default_certificate = var.initial_create ? true : false
    acm_certificate_arn            = var.initial_create ? null : var.cloudfront_certificate_arn
    minimum_protocol_version       = var.initial_create ? null : "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = var.restrict_by_geolocation ? "whitelist" : "none"
      locations        = var.restrict_by_geolocation ? ["GB"] : []
    }
  }

  logging_config {
    bucket          = aws_s3_bucket.cloudfront_access_logs.bucket_domain_name
    include_cookies = false
    prefix          = ""
  }

  tags = {
    Name = "${var.prefix}-cloudfront"
  }
}

resource "random_password" "cloudfront_header" {
  length  = 16
  special = false
}