terraform {
  required_version = "~>1.5.1"

  required_providers {
    aws = {
      version = "~>5.0"
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "core-prod-tf-state"
    dynamodb_table = "core-prod-tf-state-lock"
    encrypt        = true
    key            = "core-production.tfstate"
    region         = "eu-west-2"
    role_arn       = "arn:aws:iam::815624722760:role/developer"
  }
}

provider "aws" {
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::977287343304:role/developer"
  }
}

locals {
  prefix = "core-prod"
}

module "database" {
  source = "../modules/rds"

  prefix                            = local.prefix
  allocated_storage                 = 100
  db_subnet_group_name              = module.networking.db_private_subnet_group_name
  instance_class                    = "db.t3.small"
  ingress_source_security_group_ids = []
  vpc_id                            = module.networking.vpc_id
}

module "networking" {
  source = "../modules/networking"

  prefix                                  = local.prefix
  vpc_cidr_block                          = "10.0.0.0/16"
  vpc_flow_cloudwatch_log_expiration_days = 90
}

module "redis" {
  source = "../modules/elasticache"

  prefix                  = local.prefix
  node_type               = "cache.t2.micro"
  private_subnet_cidr     = module.networking.private_subnet_cidr
  redis_subnet_group_name = module.networking.redis_private_subnet_group_name
  vpc_id                  = module.networking.vpc_id
}

module "service" {
  source = "../modules/service"

  prefix = local.prefix
}
