resource "aws_security_group" "this" {
  name        = "${var.prefix}-ecs"
  description = "ECS security group"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "load_balancer_ingress" {
  description                  = "Allow ingress on port ${var.application_port} from the load balancer"
  ip_protocol                  = "tcp"
  from_port                    = var.application_port
  to_port                      = var.application_port
  referenced_security_group_id = var.load_balancer_security_group_id
  security_group_id            = aws_security_group.this.id
}

resource "aws_vpc_security_group_egress_rule" "db_egress" {
  description                  = "Allow egress to the database"
  ip_protocol                  = "tcp"
  from_port                    = var.database_port
  to_port                      = var.database_port
  referenced_security_group_id = var.db_security_group_id
  security_group_id            = aws_security_group.this.id
}

resource "aws_vpc_security_group_egress_rule" "redis_egress" {
  description                  = "Allow egress to redis"
  ip_protocol                  = "tcp"
  from_port                    = var.redis_port
  to_port                      = var.redis_port
  referenced_security_group_id = var.redis_security_group_id
  security_group_id            = aws_security_group.this.id
}

resource "aws_vpc_security_group_egress_rule" "http_egress" {
  description       = "Allow http egress to any IP address"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.this.id
}

resource "aws_vpc_security_group_egress_rule" "https_egress" {
  description       = "Allow https egress to any IP address"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.this.id
}
