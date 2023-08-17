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
  ingress_from_ecs_security_group_id = module.ecs.ecs_security_group_id
  instance_class                     = "db.t3.small"
  vpc_id                             = module.networking.vpc_id
}

module "ecs" {
  source = "../modules/ecs"

  prefix = local.prefix
  additional_task_role_policy_arns = {
    "RDS_access" : module.database.rds_data_access_policy_arn
    "Redis_access" : "arn:aws:iam::aws:policy/AmazonElastiCacheFullAccess"
  }
  ecr_repository_url                = "815624722760.dkr.ecr.eu-west-2.amazonaws.com/core-ecr"
  egress_to_db_security_group_id    = module.database.rds_security_group_id
  egress_to_redis_security_group_id = module.redis.redis_security_group_id
  ecs_environment_variables = [
    { Name = "API_USER", Value = "dluhc-user" },
    { Name = "APP_HOST", Value = "" },
    { Name = "CSV_DOWNLOAD_PAAS_INSTANCE", Value = "" },
    { Name = "RAILS_ENV", Value = "production" },
    { Name = "RAILS_LOG_TO_STDOUT", Value = "true" },
    { Name = "RAILS_SERVE_STATIC_FILES", Value = "true" }
  ]
  ecs_parameters         = module.parameter_store.parameter_arns
  ecs_task_cpu           = 512
  ecs_task_desired_count = 2
  ecs_task_memory        = 1024
  private_subnet_ids     = module.networking.private_subnet_ids
  vpc_id                 = module.networking.vpc_id
}

module "networking" {
  source = "../modules/networking"

  prefix                                  = local.prefix
  vpc_cidr_block                          = "10.0.0.0/16"
  vpc_flow_cloudwatch_log_expiration_days = 90
}

module "parameter_store" {
  source = "../modules/parameter_store"

  parameters = {
    "API_KEY" : {
      type  = "SecureString"
      value = var.parameters["API_KEY"]
    }
    "DATABASE_URL" : {
      type  = "SecureString"
      value = module.database.rds_db_connection_string
    }
    "EXPORT_PAAS_INSTANCE" : {
      type  = "SecureString"
      value = var.parameters["EXPORT_PAAS_INSTANCE"]
    }
    "GOVUK_NOTIFY_API_KEY" : {
      type  = "SecureString"
      value = var.parameters["GOVUK_NOTIFY_API_KEY"]
    }
    "IMPORT_PAAS_INSTANCE" : {
      type  = "SecureString"
      value = var.parameters["IMPORT_PAAS_INSTANCE"]
    }
    "OS_DATA_KEY" : {
      type  = "SecureString"
      value = var.parameters["OS_DATA_KEY"]
    }
    "RAILS_MASTER_KEY" : {
      type  = "SecureString"
      value = var.parameters["RAILS_MASTER_KEY"]
    }
    "REDIS_CONFIG" : {
      type  = "SecureString"
      value = var.parameters["REDIS_CONFIG"]
    }
    "S3_CONFIG" : {
      type  = "SecureString"
      value = var.parameters["S3_CONFIG"]
    }
    "SENTRY_DSN" : {
      type  = "SecureString"
      value = var.parameters["SENTRY_DSN"]
    }
  }
}

module "redis" {
  source = "../modules/elasticache"

  prefix                             = local.prefix
  ingress_from_ecs_security_group_id = module.ecs.ecs_security_group_id
  egress_to_ecs_security_group_id    = module.ecs.ecs_security_group_id
  node_type                          = "cache.t2.micro"
  redis_subnet_group_name            = module.networking.redis_private_subnet_group_name
  vpc_id                             = module.networking.vpc_id
}
