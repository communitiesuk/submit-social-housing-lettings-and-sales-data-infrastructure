locals {
  origin_id       = "${var.prefix}-origin"
}

resource "aws_cloudfront_distribution" "this" {
  enabled = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100" # Affects which edge locations are used by cloudfront, which affects the latency users will experience in different geographic areas

  origin {
    domain_name = aws_lb.main.dns_name
    origin_id   = local.origin_id

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 60
      origin_protocol_policy   = "match-viewer"
      origin_read_timeout      = 60
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
