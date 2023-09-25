resource "aws_security_group" "ecs" {
  name        = "${var.prefix}-db-migration-ecs"
  description = "DB migration ECS security group"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_migration_ecs_ingress" {
  description                  = "Allow ingress on port ${var.database_port} of the db from the db migration ecs"
  ip_protocol                  = "tcp"
  from_port                    = var.database_port
  to_port                      = var.database_port
  referenced_security_group_id = aws_security_group.ecs.id
  security_group_id            = var.db_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "general_egress" {
  description       = "Allow egress for cf conduit to connect to Gov PaaS services, and ECS to connect to the db and get secrets"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 0
  to_port           = 65535
  security_group_id = aws_security_group.ecs.id
}
