data "aws_availability_zones" "available" {
  state = "available"
}


# 1st arg is the prefix
# 2nd arg is the newbits - number of additional bits to extend the prefix by (left to right)
# 3rd arg is the netnum - decides what to encode into these additional bits
# Splits the VPC cidrblock into halves
locals {
  public_subnet_cidr = cidrsubnet(var.vpc_cidr_block, 1, 0)
  private_subnet_cidr = cidrsubnet(var.vpc_cidr_block, 1, 1)
}

resource "aws_subnet" "public" {
  count = 3
  availability_zone = data.aws_availability_zones.available.names[count.index]
  # Splits the public cidr block into thirds (one for each AZ)
  cidr_block = cidrsubnet(local.public_subnet_cidr, 2, count.index)
  map_public_ip_on_launch = true
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "private" {
  count = 3
  availability_zone = data.aws_availability_zones.available.names[count.index]
  # Splits the private cidr block into thirds (one for each AZ)
  cidr_block = cidrsubnet(local.private_subnet_cidr, 2, count.index)
  vpc_id = aws_vpc.main.id
}

resource "aws_db_subnet_group" "private_subnet_group" {
  name = "${var.prefix}-private-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}
