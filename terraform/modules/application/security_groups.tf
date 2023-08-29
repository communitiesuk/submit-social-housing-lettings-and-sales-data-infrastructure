resource "aws_security_group" "ecs" {
  name        = "${var.prefix}-ecs-security_group"
  description = "ECS security group"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_ingress" {
  description                  = "Allow ingress on port ${var.application_port} from the load balancer only"
  ip_protocol                  = "tcp"
  from_port                    = var.application_port
  to_port                      = var.application_port
  referenced_security_group_id = var.load_balancer_security_group_id
  security_group_id            = aws_security_group.ecs.id
}

resource "aws_vpc_security_group_egress_rule" "ecs_db_egress" {
  description                  = "Allow egress from port ${var.database_port} to the database security group"
  ip_protocol                  = "tcp"
  from_port                    = var.database_port
  to_port                      = var.database_port
  referenced_security_group_id = var.db_security_group_id
  security_group_id            = aws_security_group.ecs.id
}

resource "aws_vpc_security_group_egress_rule" "ecs_redis_egress" {
  description                  = "Allow egress from port ${var.redis_port} to the redis security group"
  ip_protocol                  = "tcp"
  from_port                    = var.redis_port
  to_port                      = var.redis_port
  referenced_security_group_id = var.redis_security_group_id
  security_group_id            = aws_security_group.ecs.id
}

resource "aws_vpc_security_group_egress_rule" "ecs_http_egress" {
  description       = "Allow egress from port 80 to any IP address"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.ecs.id
}

resource "aws_vpc_security_group_egress_rule" "ecs_https_egress" {
  description       = "Allow egress from port 443 to any IP address"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.ecs.id
}
