resource "aws_security_group" "load_balancer" {
  name        = "${var.prefix}-load-balancer-security-group"
  description = "Load Balancer security group"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "load_balancer_http_ingress" {
  description       = "Allow ingress on port 80 from from all IP addresses"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_vpc_security_group_ingress_rule" "load_balancer_https_ingress" {
  description       = "Allow ingress on port 443 from from all IP addresses"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_vpc_security_group_egress_rule" "load_balancer_http_egress" {
  description       = "Allow egress to port 80 from from all IP addresses"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_vpc_security_group_egress_rule" "load_balancer_https_egress" {
  description       = "Allow egress to port 443 from from all IP addresses"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_vpc_security_group_egress_rule" "load_balancer_container_egress" {
  description       = "Allow egress to port ${var.application_port} from from all IP addresses"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = var.application_port
  to_port           = var.application_port
  security_group_id = aws_security_group.load_balancer.id
}