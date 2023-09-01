locals {
  origin_id = "${var.prefix}-origin"
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
  enabled         = true
  http_version    = "http2and3"
  is_ipv6_enabled = true
  price_class     = "PriceClass_100" # Affects which edge locations are used by cloudfront, which affects the latency users will experience in different geographic areas

  origin {
    domain_name = aws_lb.main.dns_name
    origin_id   = local.origin_id

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id          = aws_cloudfront_cache_policy.ttl_based.id
    compress                 = true
    origin_request_policy_id = aws_cloudfront_origin_request_policy.this.id
    target_origin_id         = local.origin_id
    viewer_protocol_policy   = "allow-all"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
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
