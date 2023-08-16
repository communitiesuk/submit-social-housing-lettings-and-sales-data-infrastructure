resource "aws_security_group" "redis" {
  name        = "${var.prefix}-redis-security-group"
  description = "Redis security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow ingress on port 6379 from anything within the private subnet cidr block range"
    protocol        = "tcp"
    from_port       = 6379
    to_port         = 6379
    security_groups = var.ingress_source_security_group_ids
  }

  egress {
    description = "Allow egress from port 6379 to anything within the private subnet cidr block range"
    protocol    = "tcp"
    from_port   = 6379
    to_port     = 6379
    cidr_blocks = [var.private_subnet_cidr]
  }

  lifecycle {
    create_before_destroy = true
  }
}
