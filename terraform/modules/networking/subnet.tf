locals {
  availability_zones  = ["a", "b", "c"]
  public_subnet_cidr  = cidrsubnet(var.vpc_cidr_block, 1, 0)
  private_subnet_cidr = cidrsubnet(var.vpc_cidr_block, 1, 1)
  region              = "eu-west-2"
}

resource "aws_subnet" "public" {
  count             = length(local.availability_zones)
  availability_zone = "${local.region}${local.availability_zones[count.index]}"
  # Splits the public CIDR block into three parts (one for each AZ)
  cidr_block = cidrsubnet(local.public_subnet_cidr, 2, count.index)
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "${var.prefix}-public-subnet-${local.region}${local.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "private" {
  count             = length(local.availability_zones)
  availability_zone = "${local.region}${local.availability_zones[count.index]}"
  # Splits the private CIDR block into three parts (one for each AZ)
  cidr_block = cidrsubnet(local.private_subnet_cidr, 2, count.index)
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "${var.prefix}-private-subnet-${local.region}${local.availability_zones[count.index]}"
  }
}

resource "aws_db_subnet_group" "private" {
  name       = "${var.prefix}-db-private-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_elasticache_subnet_group" "private" {
  name       = "${var.prefix}-redis-private-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}
