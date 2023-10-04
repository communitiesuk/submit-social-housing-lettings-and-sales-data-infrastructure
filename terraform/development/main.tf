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
    role_arn = local.provider_role_arn
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"

  assume_role {
    role_arn = local.provider_role_arn
  }
}

locals {
  prefix = "core-dev"

  rails_env = "development"

  app_host                  = ""
  load_balancer_domain_name = ""

  provider_role_arn = "arn:aws:iam::837698168072:role/developer"

  app_task_desired_count = 2

  enable_aws_shield = false

  application_port = 8080
  database_port    = 5432
  redis_port       = 6379
}

module "application" {
  source = "../modules/application"

  app_task_cpu    = 512
  app_task_memory = 1024

  sidekiq_task_cpu           = 512
  sidekiq_task_desired_count = 1
  sidekiq_task_memory        = 1024

  ecr_repository_url      = "815624722760.dkr.ecr.eu-west-2.amazonaws.com/core"
  github_actions_role_arn = "arn:aws:iam::815624722760:role/core-application-repo"

  prefix                               = local.prefix
  app_host                             = local.app_host
  app_task_desired_count               = local.app_task_desired_count
  application_port                     = local.application_port
  bulk_upload_bucket_access_policy_arn = module.bulk_upload.read_write_policy_arn
  bulk_upload_bucket_details           = module.bulk_upload.details
  database_connection_string_arn       = module.database.rds_connection_string_arn
  database_data_access_policy_arn      = module.database.rds_data_access_policy_arn
  ecs_security_group_id                = module.application_security_group.ecs_security_group_id
  export_bucket_access_policy_arn      = module.cds_export.read_write_policy_arn
  export_bucket_details                = module.cds_export.details
  load_balancer_target_group_arn       = module.front_door.load_balancer_target_group_arn
  private_subnet_ids                   = module.networking.private_subnet_ids
  rails_env                            = local.rails_env
  redis_connection_string              = module.redis.redis_connection_string
  sns_topic_arn                        = module.monitoring.sns_topic_arn
}

module "application_security_group" {
  source = "../modules/application_security_group"

  prefix                          = local.prefix
  application_port                = local.application_port
  database_port                   = local.database_port
  db_security_group_id            = module.database.rds_security_group_id
  load_balancer_security_group_id = module.front_door.load_balancer_security_group_id
  redis_port                      = local.redis_port
  redis_security_group_id         = module.redis.redis_security_group_id
  vpc_id                          = module.networking.vpc_id
}

module "bulk_upload" {
  source = "../modules/bulk_upload"

  prefix = local.prefix
}

module "cds_export" {
  source = "../modules/cds_export"

  prefix = local.prefix
}

module "certificates" {
  source = "../modules/certificates"

  providers = {
    aws.us-east-1 = aws.us-east-1
  }

  cloudfront_domain_name    = local.app_host
  load_balancer_domain_name = local.load_balancer_domain_name
}

module "database" {
  source = "../modules/rds"

  allocated_storage         = 5
  apply_changes_immediately = true
  backup_retention_period   = 7
  highly_available          = false
  instance_class            = "db.t3.micro"

  prefix = local.prefix

  database_port         = local.database_port
  db_subnet_group_name  = module.networking.db_private_subnet_group_name
  ecs_security_group_id = module.application_security_group.ecs_security_group_id
  sns_topic_arn         = module.monitoring.sns_topic_arn
  vpc_id                = module.networking.vpc_id
}

module "front_door" {
  source = "../modules/front_door"

  providers = {
    aws.us-east-1 = aws.us-east-1
  }

  restrict_by_ip = false

  prefix                        = local.prefix
  app_task_desired_count        = local.app_task_desired_count
  application_port              = local.application_port
  cloudfront_certificate_arn    = module.certificates.cloudfront_certificate_arn
  cloudfront_domain_name        = local.app_host
  ecs_security_group_id         = module.application_security_group.ecs_security_group_id
  enable_aws_shield             = local.enable_aws_shield
  load_balancer_certificate_arn = module.certificates.load_balancer_certificate_arn
  load_balancer_domain_name     = local.load_balancer_domain_name
  public_subnet_ids             = module.networking.public_subnet_ids
  sns_topic_arn                 = module.monitoring.sns_topic_arn
  vpc_id                        = module.networking.vpc_id

  initial_create = var.initial_create
}

module "networking" {
  source = "../modules/networking"

  prefix                                  = local.prefix
  vpc_cidr_block                          = "10.0.0.0/16"
  vpc_flow_cloudwatch_log_expiration_days = 60
}

module "monitoring" {
  source = "../modules/monitoring"

  prefix = local.prefix
}

module "redis" {
  source = "../modules/elasticache"

  apply_changes_immediately = true
  highly_available          = false
  node_type                 = "cache.t4g.micro"

  prefix                  = local.prefix
  ecs_security_group_id   = module.application_security_group.ecs_security_group_id
  redis_port              = local.redis_port
  redis_subnet_group_name = module.networking.redis_private_subnet_group_name
  vpc_id                  = module.networking.vpc_id
}
