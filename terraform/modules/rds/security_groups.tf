resource "aws_security_group" "this" {
  name        = "${var.prefix}-rds"
  description = "RDS security group"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_ingress" {
  description                  = "Allow ingress on port ${var.database_port} from ecs"
  ip_protocol                  = "tcp"
  from_port                    = var.database_port
  to_port                      = var.database_port
  referenced_security_group_id = var.ecs_security_group_id
  security_group_id            = aws_security_group.this.id
}
