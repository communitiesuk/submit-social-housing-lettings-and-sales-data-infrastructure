resource "aws_acm_certificate" "cloudfront" {
  domain_name               = var.cloudfront_domain_name
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
