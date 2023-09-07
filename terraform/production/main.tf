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
  prefix           = "core-prod"
  application_port = 8080
  database_port    = 5432
  redis_port       = 6379
}

module "database" {
  source = "../modules/rds"

  prefix                = local.prefix
  allocated_storage     = 100
  database_port         = local.database_port
  db_subnet_group_name  = module.networking.db_private_subnet_group_name
  ecs_security_group_id = module.application.ecs_security_group_id
  instance_class        = "db.t3.small"
  vpc_id                = module.networking.vpc_id
}

module "bulk_upload" {
  source = "../modules/bulk_upload"

  prefix = local.prefix
}

module "cds_export" {
  source = "../modules/cds_export"

  prefix = local.prefix
}

module "application" {
  source = "../modules/application"

  prefix                               = local.prefix
  app_host                             = ""
  application_port                     = local.application_port
  bulk_upload_bucket_access_policy_arn = module.bulk_upload.read_write_policy_arn
  bulk_upload_bucket_details           = module.bulk_upload.details
  database_connection_string_arn       = module.database.rds_connection_string_arn
  database_data_access_policy_arn      = module.database.rds_data_access_policy_arn
  database_port                        = local.database_port
  db_security_group_id                 = module.database.rds_security_group_id
  ecr_repository_url                   = "815624722760.dkr.ecr.eu-west-2.amazonaws.com/core"
  ecs_task_cpu                         = 512
  ecs_task_desired_count               = 2
  ecs_task_memory                      = 1024
  export_bucket_access_policy_arn      = module.cds_export.read_write_policy_arn
  export_bucket_details                = module.cds_export.details
  github_actions_role_arn              = "arn:aws:iam::815624722760:role/core-application-repo"
  load_balancer_security_group_id      = module.front_door.load_balancer_security_group_id
  load_balancer_target_group_arn       = module.front_door.load_balancer_target_group_arn
  private_subnet_ids                   = module.networking.private_subnet_ids
  redis_connection_string              = module.redis.redis_connection_string
  rails_env                            = "production"
  redis_port                           = local.redis_port
  redis_security_group_id              = module.redis.redis_security_group_id
  vpc_id                               = module.networking.vpc_id
}

module "front_door" {
  source = "../modules/front_door"

  prefix                = local.prefix
  application_port      = local.application_port
  ecs_security_group_id = module.application.ecs_security_group_id
  public_subnet_ids     = module.networking.public_subnet_ids
  vpc_id                = module.networking.vpc_id
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
