resource "aws_security_group" "rds" {
 name        = "${var.prefix}-rds-security-group"
 description = "RDS security group"
 vpc_id      = var.vpc_id

 ingress {
   description     = "Allow ingress on port 5432 only from the specified security groups"
   security_groups = var.security_group_ids
   from_port       = 5432
   to_port         = 5432
   protocol        = "tcp"
 }

 lifecycle {
   create_before_destroy = true
 }
}
