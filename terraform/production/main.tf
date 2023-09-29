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
  prefix                    = "core-prod"
  app_host                  = "submit-social-housing-data.levellingup.gov.uk"
  app_task_desired_count    = 2
  application_port          = 8080
  create_db_migration_infra = false
  database_port             = 5432
  load_balancer_domain_name = "lb.submit-social-housing-data.levellingup.gov.uk"
  provider_role_arn         = "arn:aws:iam::977287343304:role/developer"
  redis_port                = 6379
}

module "application" {
  source = "../modules/application"

  prefix                               = local.prefix
  app_host                             = ""
  app_task_cpu                         = 512
  app_task_desired_count               = local.app_task_desired_count
  app_task_memory                      = 1024
  application_port                     = local.application_port
  bulk_upload_bucket_access_policy_arn = module.bulk_upload.read_write_policy_arn
  bulk_upload_bucket_details           = module.bulk_upload.details
  database_connection_string_arn       = module.database.rds_connection_string_arn
  database_data_access_policy_arn      = module.database.rds_data_access_policy_arn
  database_port                        = local.database_port
  db_security_group_id                 = module.database.rds_security_group_id
  ecr_repository_url                   = "815624722760.dkr.ecr.eu-west-2.amazonaws.com/core"
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
  sidekiq_task_cpu                     = 1024
  sidekiq_task_desired_count           = 1
  sidekiq_task_memory                  = 8192
  sns_topic_arn                        = module.monitoring.sns_topic_arn
  vpc_id                               = module.networking.vpc_id
}

module "bulk_upload" {
  source = "../modules/bulk_upload"

  prefix = local.prefix
}

module "cds_export" {
  source = "../modules/cds_export"

  prefix = local.prefix
  cds_access_role_arns = [
    "arn:aws:iam::062321884391:role/DSQL1",
    "arn:aws:iam::062321884391:role/DSQSS"
  ]
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

  prefix                  = local.prefix
  allocated_storage       = 100
  backup_retention_period = 7
  database_port           = local.database_port
  db_subnet_group_name    = module.networking.db_private_subnet_group_name
  ecs_security_group_id   = module.application.ecs_security_group_id
  highly_available        = true
  instance_class          = "db.t3.small"
  sns_topic_arn           = module.monitoring.sns_topic_arn
  vpc_id                  = module.networking.vpc_id
}

module "database_migration" {
  source = "../modules/rds_migration"

  count = local.create_db_migration_infra ? 1 : 0

  prefix                         = local.prefix
  database_connection_string_arn = module.database.rds_connection_string_arn
  database_port                  = local.database_port
  db_migration_task_cpu          = 4096
  db_migration_task_memory       = 16384
  db_security_group_id           = module.database.rds_security_group_id
  ecr_repository_url             = "815624722760.dkr.ecr.eu-west-2.amazonaws.com/db-migration"
  ecs_task_role_arn              = module.application.ecs_task_role_arn
  ecs_task_execution_role_arn    = module.application.ecs_task_execution_role_arn
  ecs_task_execution_role_name   = module.application.ecs_task_execution_role_name
  ecs_task_ephemeral_storage     = 200 #GiB
  private_subnet_ids             = module.networking.private_subnet_ids
  vpc_id                         = module.networking.vpc_id
}

module "front_door" {
  source = "../modules/front_door"

  providers = {
    aws.us-east-1 = aws.us-east-1
  }

  prefix                        = local.prefix
  app_task_desired_count        = local.app_task_desired_count
  application_port              = local.application_port
  cloudfront_certificate_arn    = module.certificates.cloudfront_certificate_arn
  cloudfront_domain_name        = local.app_host
  ecs_security_group_id         = module.application.ecs_security_group_id
  load_balancer_certificate_arn = module.certificates.load_balancer_certificate_arn
  load_balancer_domain_name     = local.load_balancer_domain_name
  public_subnet_ids             = module.networking.public_subnet_ids
  sns_topic_arn                 = module.monitoring.sns_topic_arn
  vpc_id                        = module.networking.vpc_id
}

module "networking" {
  source = "../modules/networking"

  prefix                                  = local.prefix
  vpc_cidr_block                          = "10.0.0.0/16"
  vpc_flow_cloudwatch_log_expiration_days = 90
}

module "monitoring" {
  source = "../modules/monitoring"

  prefix = local.prefix
}

module "redis" {
  source = "../modules/elasticache"

  prefix                  = local.prefix
  ecs_security_group_id   = module.application.ecs_security_group_id
  highly_available        = true
  node_type               = "cache.t4g.micro"
  redis_port              = local.redis_port
  redis_subnet_group_name = module.networking.redis_private_subnet_group_name
  vpc_id                  = module.networking.vpc_id
}
