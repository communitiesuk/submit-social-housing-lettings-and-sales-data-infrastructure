resource "aws_security_group" "redis" {
  name        = "${var.prefix}-redis-security-group"
  description = "Redis security group"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "redis_ingress" {
  description                  = "Allow ingress on port ${var.redis_port} from from the ecs security group"
  ip_protocol                  = "tcp"
  from_port                    = var.redis_port
  to_port                      = var.redis_port
  referenced_security_group_id = var.ingress_from_ecs_security_group_id
  security_group_id            = aws_security_group.redis.id
}

resource "aws_vpc_security_group_egress_rule" "redis_egress" {
  description                  = "Allow egress from port ${var.redis_port} to to ecs security group"
  ip_protocol                  = "tcp"
  from_port                    = var.redis_port
  to_port                      = var.redis_port
  referenced_security_group_id = var.egress_to_ecs_security_group_id
  security_group_id            = aws_security_group.redis.id
}
