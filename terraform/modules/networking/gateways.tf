resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

resource "aws_eip" "nat_gateway" {
  #checkov:skip=CKV2_AWS_19:it's acceptable to associate an EIP with a NAT gateway, but Checkov is expecting it to be associated with an EC2 instance. We think this is a false flag
  count  = length(aws_subnet.private)
  domain = "vpc"

  tags = {
    Name = "${var.prefix}-nat-gateway-eip-${count.index}"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "this" {
  count         = length(aws_subnet.private)
  allocation_id = element(aws_eip.nat_gateway[*].id, count.index)
  subnet_id     = element(aws_subnet.public[*].id, count.index)

  tags = {
    Name = "${var.prefix}-nat-gateway-${count.index}"
  }

  depends_on = [aws_internet_gateway.main]
}
