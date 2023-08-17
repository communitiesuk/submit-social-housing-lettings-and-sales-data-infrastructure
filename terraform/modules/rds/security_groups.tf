resource "aws_security_group" "rds" {
  name        = "${var.prefix}-rds-security-group"
  description = "RDS security group"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_ingress" {
  description                  = "Allow ingress on port 6379 from ecs security group"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = var.ingress_from_ecs_security_group_id
  security_group_id            = aws_security_group.rds.id
}
