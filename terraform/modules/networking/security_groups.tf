resource "aws_default_security_group" "default-eu-west-2" {
  vpc_id = data.aws_vpc.default-eu-west-2.id
}

resource "aws_default_security_group" "default-eu-west-1" {
  provider = aws.eu-west-1

  vpc_id = data.aws_vpc.default-eu-west-1.id
}

resource "aws_default_security_group" "default-eu-west-3" {
  provider = aws.eu-west-3

  vpc_id = data.aws_vpc.default-eu-west-3.id
}

resource "aws_default_security_group" "default-us-east-1" {
  provider = aws.us-east-1

  vpc_id = data.aws_vpc.default-us-east-1.id
}
