resource "aws_security_group" "redis" {
  name        = "${var.prefix}-redis"
  description = "Redis security group"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "redis_ingress" {
  description                  = "Allow ingress on port ${var.redis_port} from ecs"
  ip_protocol                  = "tcp"
  from_port                    = var.redis_port
  to_port                      = var.redis_port
  referenced_security_group_id = var.ecs_security_group_id
  security_group_id            = aws_security_group.redis.id
}
