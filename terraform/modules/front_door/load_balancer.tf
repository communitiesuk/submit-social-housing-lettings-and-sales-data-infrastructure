#tfsec:ignore:aws-elb-alb-not-public:the load balancer must be exposed to the internet in order to communicate with cloudfront
resource "aws_lb" "this" {
  #checkov:skip=CKV_AWS_91:setup access logs on load balancer TODO CLDC-2705
  #checkov:skip=CKV2_AWS_28:WAF on LB is unnecessary as we have protections preventing traffic from bypassing cloudfront which already has WAF protection
  name                       = var.prefix
  drop_invalid_header_fields = true
  enable_deletion_protection = true
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.load_balancer.id]
  subnets                    = var.public_subnet_ids

  access_logs {
    enabled = true
    bucket  = aws_s3_bucket.load_balancer_access_logs.id
    prefix  = ""
  }
}

resource "aws_lb_listener" "https" {
  count = var.initial_create ? 0 : 1

  certificate_arn   = var.load_balancer_certificate_arn
  load_balancer_arn = aws_lb.this.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "403: Forbidden"
      status_code  = "403"
    }

    order = 50000 # this is the highest value possible so will be performed last out of all listener rules
  }
}

resource "aws_lb_listener_certificate" "additional_cert" {
  count = var.initial_create ? 0 : 1

  listener_arn    = aws_lb_listener.https[0].arn
  certificate_arn = var.load_balancer_additional_certificate_arn
}
