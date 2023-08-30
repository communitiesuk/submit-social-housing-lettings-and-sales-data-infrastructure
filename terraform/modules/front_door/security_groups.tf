resource "aws_security_group" "load_balancer" {
  name        = "${var.prefix}-load-balancer-security-group"
  description = "Load Balancer security group"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "load_balancer_http_ingress" {
  #checkov:skip=CKV_AWS_260:ingress from all IPs to port 80 required as load balancer is public
  description       = "Allow http ingress from all IP addresses"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_vpc_security_group_ingress_rule" "load_balancer_https_ingress" {
  description       = "Allow https ingress from all IP addresses"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_vpc_security_group_egress_rule" "load_balancer_container_egress" {
  description                  = "Allow egress to ecs"
  ip_protocol                  = "tcp"
  from_port                    = var.application_port
  to_port                      = var.application_port
  referenced_security_group_id = var.ecs_security_group_id
  security_group_id            = aws_security_group.load_balancer.id
}