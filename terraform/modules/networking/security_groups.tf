resource "aws_default_security_group" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_default_security_group" "default_eu_west_2" {
  vpc_id = data.aws_vpc.default_eu_west_2.id
}

resource "aws_default_security_group" "default_eu_west_1" {
  provider = aws.eu-west-1

  vpc_id = data.aws_vpc.default_eu_west_1.id
}

resource "aws_default_security_group" "default_eu_west_3" {
  provider = aws.eu-west-3

  vpc_id = data.aws_vpc.default_eu_west_3.id
}

resource "aws_default_security_group" "default_us_east_1" {
  provider = aws.us-east-1

  vpc_id = data.aws_vpc.default_us_east_1.id
}
