data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  public_subnet_cidr  = cidrsubnet(var.vpc_cidr_block, 1, 0)
  private_subnet_cidr = cidrsubnet(var.vpc_cidr_block, 1, 1)
}

resource "aws_subnet" "public" {
  count             = 3
  availability_zone = data.aws_availability_zones.available.names[count.index]
  # Splits the public CIDR block into three parts (one for each AZ)
  cidr_block = cidrsubnet(local.public_subnet_cidr, 2, count.index)
  vpc_id     = aws_vpc.main.id
}

resource "aws_subnet" "private" {
  count             = 3
  availability_zone = data.aws_availability_zones.available.names[count.index]
  # Splits the private CIDR block into three parts (one for each AZ)
  cidr_block = cidrsubnet(local.private_subnet_cidr, 2, count.index)
  vpc_id     = aws_vpc.main.id
}

resource "aws_db_subnet_group" "private_subnet_group" {
  name       = "${var.prefix}-private-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}
