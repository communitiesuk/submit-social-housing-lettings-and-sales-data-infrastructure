terraform {
  required_version = "~>1.5.1"

  required_providers {
    aws = {
      version = "~>5.0"
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "core-non-prod-tf-state"
    dynamodb_table = "core-non-prod-tf-state-lock"
    encrypt        = true
    key            = "core-development.tfstate"
    region         = "eu-west-2"
    role_arn       = "arn:aws:iam::815624722760:role/developer"
  }
}

provider "aws" {
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::837698168072:role/developer"
  }
}

module "networking" {
  source = "../modules/networking"

  prefix                                  = "core-dev"
  vpc_cidr_block                          = "10.0.0.0/16"
  vpc_flow_cloudwatch_log_expiration_days = 90
}

module "rds" {
  source = "../modules/rds"

  prefix               = "core-dev"
  allocated_storage    = 5
  db_subnet_group_name = module.networking.private_subnet_group_name
  instance_class       = "db.t3.micro"
  security_group_ids   = []
  vpc_id               = module.networking.vpc_id
}

module "service" {
  source = "../modules/service"

  prefix = "core-stag"
}
