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

  prefix                             = local.prefix
  allocated_storage                  = 100
  db_subnet_group_name               = module.networking.db_private_subnet_group_name
  ingress_from_ecs_security_group_id = module.application.ecs_security_group_id
  instance_class                     = "db.t3.small"
  vpc_id                             = module.networking.vpc_id
}

module "application" {
  source = "../modules/application"

  prefix                            = local.prefix
  app_host                          = ""
  database_data_access_policy_arn   = module.database.rds_data_access_policy_arn
  database_connection_string_arn    = module.database.rds_connection_string_arn
  ecr_repository_url                = "815624722760.dkr.ecr.eu-west-2.amazonaws.com/core-ecr"
  egress_to_db_security_group_id    = module.database.rds_security_group_id
  egress_to_redis_security_group_id = module.redis.redis_security_group_id
  ecs_task_cpu                      = 512
  ecs_task_desired_count            = 2
  ecs_task_memory                   = 1024
  private_subnet_ids                = module.networking.private_subnet_ids
  rails_env                         = "production"
  redis_connection_string           = module.redis.redis_connection_string
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

  prefix                             = local.prefix
  ingress_from_ecs_security_group_id = module.application.ecs_security_group_id
  egress_to_ecs_security_group_id    = module.application.ecs_security_group_id
  node_type                          = "cache.t2.micro"
  redis_subnet_group_name            = module.networking.redis_private_subnet_group_name
  vpc_id                             = module.networking.vpc_id
}
