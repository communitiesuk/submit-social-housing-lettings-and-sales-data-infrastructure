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
    key            = "core-staging.tfstate"
    region         = "eu-west-2"
    role_arn       = "arn:aws:iam::815624722760:role/developer"
  }
}

provider "aws" {
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::107155005276:role/developer"
  }
}

locals {
  prefix           = "core-stag"
  application_port = 8080
  database_port    = 5432
  redis_port       = 6379
}

module "database" {
  source = "../modules/rds"

  prefix                = local.prefix
  allocated_storage     = 5
  database_port         = local.database_port
  db_subnet_group_name  = module.networking.db_private_subnet_group_name
  ecs_security_group_id = module.application.ecs_security_group_id
  instance_class        = "db.t3.micro"
  vpc_id                = module.networking.vpc_id
}

module "cds_export" {
  source = "../modules/cds_export"

  prefix = local.prefix
}

module "application" {
  source = "../modules/application"

  prefix                            = local.prefix
  app_host                          = ""
  application_port                  = local.application_port
  database_data_access_policy_arn   = module.database.rds_data_access_policy_arn
  database_connection_string_arn    = module.database.rds_connection_string_arn
  database_port                     = local.database_port
  db_security_group_id              = module.database.rds_security_group_id
  ecr_repository_url                = "815624722760.dkr.ecr.eu-west-2.amazonaws.com/core-ecr"
  redis_security_group_id           = module.redis.redis_security_group_id
  ecs_task_cpu                      = 512
  ecs_task_desired_count            = 2
  ecs_task_memory                   = 1024
  export_bucket_access_policy_arn   = module.cds_export.read_write_policy_arn
  export_bucket_details             = module.cds_export.details
  load_balancer_target_group_arn    = module.front_door.load_balancer_target_group_arn
  private_subnet_ids                = module.networking.private_subnet_ids
  rails_env                         = "staging"
  redis_connection_string           = module.redis.redis_connection_string
  redis_port                        = local.redis_port
  vpc_id                            = module.networking.vpc_id
}

module "front_door" {
  source = "../modules/front_door"

  prefix            = local.prefix
  application_port  = local.application_port
  public_subnet_ids = module.networking.public_subnet_ids
  vpc_id            = module.networking.vpc_id
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
  ecs_security_group_id   = module.application.ecs_security_group_id
  node_type               = "cache.t2.micro"
  redis_port              = local.redis_port
  redis_subnet_group_name = module.networking.redis_private_subnet_group_name
  vpc_id                  = module.networking.vpc_id
}
