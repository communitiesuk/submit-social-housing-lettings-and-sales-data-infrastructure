resource "aws_security_group" "this" {
  #checkov:skip=CKV2_AWS-57: This security group is used when manually triggering these tasks
  name        = "${var.prefix}-s3-migration"
  description = "Security group for s3 migration tasks"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "this" {
  description       = "Allow general https egress to reach old and new buckets"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.this.id
}