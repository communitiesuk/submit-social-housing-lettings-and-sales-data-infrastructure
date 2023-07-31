# Public subnets should route internet traffic to the Internet Gateway
## TODO - do we have multiple VPCs or just one? If multiple, we need to introduce count here.
resource "aws_route_table" "public_to_igw" {
  vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "${var.prefix}-route-table-to-igw"
#   }
}

## TODO - do we have multiple VPCs or just one? If multiple, we need to introduce count here.
resource "aws_route" "public_to_igw" {
  route_table_id         = aws_route_table.public_to_igw.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_to_igw" {
  count          = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public_to_igw.id
}

# Private subnets should route traffic to the NAT gateway
# This setup may change (for example if we add a firewall in the middle, as was done on Delta)
resource "aws_route_table" "private_to_ngw" {
  count  = length(aws_nat_gateway.main)
  vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "${var.prefix}-route-table-to-ngw-${count.index}"
#   }
}

resource "aws_route" "private_to_ngw" {
  count                  = length(aws_nat_gateway.main)
  route_table_id         = element(aws_route_table.private_to_ngw[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.main[*].id, count.index)
}

resource "aws_route_table_association" "private_to_ngw" {
  count          = length(aws_subnet.private)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private_to_ngw[*].id, count.index)
}
