resource "aws_lb" "main" {
  name                       = "${var.prefix}-load-balancer"
  drop_invalid_header_fields = true
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.load_balancer.id]
  subnets                    = var.public_subnet_ids
}

resource "aws_lb_target_group" "main" {
  name        = "${var.prefix}-target-group"
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

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.main.id
    type             = "forward"
  }

  lifecycle {
    replace_triggered_by = [aws_lb_target_group.main.id]
  }
}
