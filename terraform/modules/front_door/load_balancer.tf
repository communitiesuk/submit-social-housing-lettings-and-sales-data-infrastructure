#tfsec:ignore:aws-elb-alb-not-public:load balancer is exposed to internet as it receives traffic from public
resource "aws_lb" "this" {
  #checkov:skip=CKV_AWS_91:setup access logs on load balancer TODO CLDC-2705
  #checkov:skip=CKV2_AWS_20:redirect http requests to https TODO CLDC-2654
  #checkov:skip=CKV2_AWS_28:WAF protection to be setup TODO CLDC-2546
  name                       = "${var.prefix}"
  drop_invalid_header_fields = true
  enable_deletion_protection = true
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.load_balancer.id]
  subnets                    = var.public_subnet_ids
}

resource "aws_lb_target_group" "this" {
  name        = "${var.prefix}"
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

#tfsec:ignore:aws-elb-http-not-used:https between cloudfront and load balancer will be implemented here TODO CLDC-2654
resource "aws_lb_listener" "http" {
  #checkov:skip=CKV_AWS_103:ssl policy for https listener will be implemented here TODO CLDC-2654
  #checkov:skip=CKV_AWS_2:https between cloudfront and load balancer will be implemented here TODO CLDC-2654
  load_balancer_arn = aws_lb.this.id
  port              = 80
  protocol          = "HTTP"

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
  listener_arn = aws_lb_listener.http.arn
  priority     = 1

  action {
    target_group_arn = aws_lb_target_group.this.id
    type             = "forward"
  }

  condition {
    http_header {
      http_header_name = local.cloudfront_header_name
      values           = [random_password.this.result]
    }
  }
}
