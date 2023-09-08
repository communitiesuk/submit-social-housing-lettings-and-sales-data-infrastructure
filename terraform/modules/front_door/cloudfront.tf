locals {
  origin_id              = "${var.prefix}-origin"
  cloudfront_header_name = "X-CLOUDFRONT-HEADER"
}

#tfsec:ignore:aws-cloudfront-enable-logging:TODO we will be implementing logging later
#tfsec:ignore:aws-cloudfront-enable-waf:TODO CLDC-2546
#tfsec:ignore:aws-cloudfront-enforce-https:TODO CLDC-2654
#tfsec:ignore:aws-cloudfront-use-secure-tls-policy:TODO CLDC-2680
resource "aws_cloudfront_distribution" "this" {
  #checkov:skip=CKV_AWS_34:TODO CLDC-2654
  #checkov:skip=CKV2_AWS_42:TODO CLDC-2680
  #checkov:skip=CKV2_AWS_47:TODO CLDC-2546 when setting up WAF it should be configured appropriately to mitigate against the Log4j vulnerability https://docs.bridgecrew.io/docs/ensure-aws-cloudfront-attached-wafv2-webacl-is-configured-with-amr-for-log4j-vulnerability
  #checkov:skip=CKV_AWS_68:TODO CLDC-2546
  #checkov:skip=CKV_AWS_86:TODO we will be implementing logging later
  #checkov:skip=CKV_AWS_174:TODO CLDC-2680
  #checkov:skip=CKV_AWS_305:no need to define a default root object because the root of our distribution is just the app's homepage
  #checkov:skip=CKV_AWS_310:we have decided that we're unlikely to need a secondary load balancer
  aliases         = [var.cloudfront_domain_name]
  enabled         = true
  http_version    = "http2and3"
  is_ipv6_enabled = true
  price_class     = "PriceClass_100" # Affects which edge locations are used by cloudfront, which affects the latency users will experience in different geographic areas

  origin {
    domain_name = aws_lb.this.dns_name
    origin_id   = local.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
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
    acm_certificate_arn      = var.cloudfront_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "${var.prefix}-cloudfront"
  }
}

resource "random_password" "cloudfront_header" {
  length  = 16
  special = false
}