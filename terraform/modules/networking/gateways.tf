resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  # tags = {
  #   Name = "${var.prefix}-internet-gateway"
  # }
}

resource "aws_eip" "nat_gateway" {
  count = length(aws_subnet.private)
  domain = "vpc"

  # tags = {
  #   Name = "${var.prefix}-ngw-eip-${count.index}"
  # }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count         = length(aws_subnet.private)
  allocation_id = element(aws_eip.nat_gateway[*].id, count.index)
  subnet_id     = element(aws_subnet.public[*].id, count.index)

  # tags = {
  #   Name = "${var.prefix}-ngw-${count.index}"
  # }

  depends_on = [aws_internet_gateway.this]
}
