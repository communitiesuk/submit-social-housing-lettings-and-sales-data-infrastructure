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
    path                = "${var.relative_root}/health"
    unhealthy_threshold = "2"
  }
}

resource "aws_lb_listener_rule" "forward" {
  listener_arn = var.load_balancer_listener_arn

  action {
    target_group_arn = aws_lb_target_group.this.id
    type             = "forward"
  }

  condition {
    http_header {
      http_header_name = var.cloudfront_header_name
      values           = [var.cloudfront_header_password]
    }
  }

  condition {
    path_pattern {
      values = [var.relative_root, "${var.relative_root}/*"]
    }
  }
}
