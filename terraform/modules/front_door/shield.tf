resource "aws_shield_protection" "cloudfront" {
  count        = var.enable_aws_shield ? 1 : 0
  name         = "${var.prefix}-cloudfront"
  resource_arn = aws_cloudfront_distribution.this.arn
}

resource "aws_shield_application_layer_automatic_response" "cloudfront" {
  count        = var.enable_aws_shield ? 1 : 0
  action       = "BLOCK"
  resource_arn = aws_cloudfront_distribution.this.arn
}

resource "aws_shield_protection" "load_balancer" {
  count        = var.enable_aws_shield ? 1 : 0
  name         = "${var.prefix}-load-balancer"
  resource_arn = aws_lb.this.arn
}

resource "aws_shield_application_layer_automatic_response" "load_balancer" {
  count        = var.enable_aws_shield ? 1 : 0
  action       = "BLOCK"
  resource_arn = aws_lb.this.arn
}

resource "aws_shield_protection_group" "this" {
  count        = var.enable_aws_shield ? 1 : 0
  protection_group_id = var.prefix
  aggregation         = "MAX"
  pattern             = "ALL"
}
