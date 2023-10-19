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
    key            = "core-review.tfstate"
    region         = "eu-west-2"
    role_arn       = "arn:aws:iam::815624722760:role/developer"
  }
}

data "terraform_remote_state" "development" {
  backend   = "s3"
  workspace = "default"

  config = {
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

locals {
  prefix = "core-dev"

  rails_env = "development"

  default_database_name = "data_collector"

  app_host = "review.submit-social-housing-data.levellingup.gov.uk"

  provider_role_arn = "arn:aws:iam::837698168072:role/developer"

  app_task_desired_count = 2

  application_port = 8080
  redis_port       = 6379
}

module "application" {
  source = "../../modules/application"

  app_task_cpu    = 512
  app_task_memory = 1024

  sidekiq_task_cpu           = 512
  sidekiq_task_desired_count = 1
  sidekiq_task_memory        = 1024

  ecr_repository_url = "815624722760.dkr.ecr.eu-west-2.amazonaws.com/core"

  prefix                                            = local.prefix
  api_key_secret_arn                                = data.terraform_remote_state.development.outputs.application_secrets_api_key_secret_arn
  app_host                                          = local.app_host
  app_task_desired_count                            = local.app_task_desired_count
  application_port                                  = local.application_port
  bulk_upload_bucket_details                        = data.terraform_remote_state.development.outputs.bulk_upload_details
  cloudfront_header_name                            = data.terraform_remote_state.development.outputs.front_door_cloudfront_header_name
  cloudfront_header_password                        = data.terraform_remote_state.development.outputs.front_door_cloudfront_header_password
  database_name                                     = "${local.prefix}-${local.default_database_name}"
  database_partial_connection_string_parameter_name = data.terraform_remote_state.development.outputs.database_rds_partial_connection_string_parameter_name
  ecs_deployment_role_name                          = data.terraform_remote_state.development.outputs.application_roles_ecs_deployment_role_name
  ecs_security_group_id                             = data.terraform_remote_state.development.outputs.application_security_group_ecs_security_group_id
  ecs_task_execution_role_arn                       = data.terraform_remote_state.development.outputs.application_roles_ecs_task_execution_role_arn
  ecs_task_execution_role_id                        = data.terraform_remote_state.development.outputs.application_roles_ecs_task_execution_role_id
  ecs_task_role_arn                                 = data.terraform_remote_state.development.outputs.application_roles_ecs_task_role_arn
  export_bucket_details                             = data.terraform_remote_state.development.outputs.cds_export_details
  govuk_notify_api_key_secret_arn                   = data.terraform_remote_state.development.outputs.application_secrets_govuk_notify_api_key_secret_arn
  load_balancer_arn_suffix                          = data.terraform_remote_state.development.outputs.front_door_load_balancer_arn_suffix
  load_balancer_listener_arn                        = data.terraform_remote_state.development.outputs.front_door_load_balancer_listener_arn
  os_data_key_secret_arn                            = data.terraform_remote_state.development.outputs.application_secrets_os_data_key_secret_arn
  private_subnet_ids                                = data.terraform_remote_state.development.outputs.networking_private_subnet_ids
  rails_env                                         = local.rails_env
  rails_master_key_secret_arn                       = data.terraform_remote_state.development.outputs.application_secrets_rails_master_key_secret_arn
  redis_connection_string                           = module.redis.redis_connection_string
  sentry_dsn_secret_arn                             = data.terraform_remote_state.development.outputs.application_secrets_sentry_dsn_secret_arn
  sns_topic_arn                                     = data.terraform_remote_state.development.outputs.monitoring_sns_topic_arn
  vpc_id                                            = data.terraform_remote_state.development.outputs.networking_vpc_id
}

module "redis" {
  source = "../../modules/elasticache"

  apply_changes_immediately = true
  highly_available          = false
  node_type                 = "cache.t4g.micro"

  prefix                  = local.prefix
  redis_port              = local.redis_port
  redis_security_group_id = data.terraform_remote_state.development.outputs.redis_security_group_id
  redis_subnet_group_name = data.terraform_remote_state.development.outputs.redis_private_subnet_group_name
}
