resource "aws_security_group" "redis" {
  name        = "${var.prefix}-redis-security-group"
  description = "Redis security group"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "redis_ingress" {
  description                  = "Allow ingress on port 6379 from from the ecs security group"
  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379
  referenced_security_group_id = var.ingress_from_ecs_security_group_id
  security_group_id            = aws_security_group.redis.id
}

resource "aws_vpc_security_group_egress_rule" "redis_egress" {
  description                  = "Allow egress from port 6379 to to ecs security group"
  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379
  referenced_security_group_id = var.ingress_from_ecs_security_group_id
  security_group_id            = aws_security_group.redis.id
}
