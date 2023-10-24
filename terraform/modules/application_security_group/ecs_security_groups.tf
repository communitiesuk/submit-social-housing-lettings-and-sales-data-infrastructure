resource "aws_security_group" "ecs" {
  #checkov:skip=CKV2_AWS_5: security group is attached to a resource outside of this module
  name        = "${var.prefix}-ecs"
  description = "ECS security group"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_from_load_balancer" {
  description                  = "Allow ingress on port ${var.application_port} from the load balancer"
  ip_protocol                  = "tcp"
  from_port                    = var.application_port
  to_port                      = var.application_port
  referenced_security_group_id = var.load_balancer_security_group_id
  security_group_id            = aws_security_group.ecs.id
}

resource "aws_vpc_security_group_egress_rule" "egress_to_db" {
  description                  = "Allow egress to the database"
  ip_protocol                  = "tcp"
  from_port                    = var.database_port
  to_port                      = var.database_port
  referenced_security_group_id = var.db_security_group_id
  security_group_id            = aws_security_group.ecs.id
}

resource "aws_vpc_security_group_egress_rule" "egress_to_redis" {
  description                  = "Allow egress to redis"
  ip_protocol                  = "tcp"
  from_port                    = var.redis_port
  to_port                      = var.redis_port
  referenced_security_group_id = aws_security_group.redis.id
  security_group_id            = aws_security_group.ecs.id
}

resource "aws_vpc_security_group_egress_rule" "http_egress" {
  description       = "Allow http egress to any IP address"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.ecs.id
}

resource "aws_vpc_security_group_egress_rule" "https_egress" {
  description       = "Allow https egress to any IP address"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.ecs.id
}
