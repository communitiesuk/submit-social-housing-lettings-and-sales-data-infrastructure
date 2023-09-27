resource "aws_wafv2_web_acl_association" "this" {
  resource_arn = aws_lb.this.arn
  web_acl_arn  = aws_wafv2_web_acl.load_balancer.arn
}

#tfsec:ignore:aws-elb-alb-not-public:the load balancer must be exposed to the internet in order to communicate with cloudfront
resource "aws_lb" "this" {
  #checkov:skip=CKV_AWS_91:setup access logs on load balancer TODO CLDC-2705
  name                       = var.prefix
  drop_invalid_header_fields = true
  enable_deletion_protection = true
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.load_balancer.id]
  subnets                    = var.public_subnet_ids
}

resource "aws_lb_target_group" "this" {
  name        = var.prefix
  port        = var.application_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "204"
    timeout             = "3"
    path                = "/health"
    unhealthy_threshold = "2"
  }
}

resource "aws_lb_listener" "https" {
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
  }

  lifecycle {
    replace_triggered_by = [aws_lb_target_group.this.id]
  }
}

resource "aws_lb_listener_rule" "forward_cloudfront" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 1

  action {
    target_group_arn = aws_lb_target_group.this.id
    type             = "forward"
  }

  condition {
    http_header {
      http_header_name = local.cloudfront_header_name
      values           = [random_password.cloudfront_header.result]
    }
  }
}
