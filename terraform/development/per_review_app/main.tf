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
    key            = "core-development-per-review-app.tfstate"
    region         = "eu-west-2"
  }
}

data "terraform_remote_state" "development_shared" {
  backend   = "s3"
  workspace = "default"

  config = {
    bucket         = "core-non-prod-tf-state"
    dynamodb_table = "core-non-prod-tf-state-lock"
    encrypt        = true
    key            = "core-development-shared.tfstate"
    region         = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"

  assume_role {
    role_arn = local.provider_role_arn
  }
}

locals {
  prefix = "core-review-${terraform.workspace}" # terraform workspaces are expected to have a number"

  rails_env = "review"

  app_host = "review.submit-social-housing-data.communities.gov.uk"

  provider_role_arn = data.terraform_remote_state.development_shared.outputs.deployment_role_arn

  app_task_desired_count = 1

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

  out_of_hours_scale_down = {
    enabled = true
    timings = {
      workday_start = "0 8"
      workday_end   = "0 19"
    }
    scale_to = {
      app     = 0
      sidekiq = 0
    }
  }

  ecr_repository_url = "815624722760.dkr.ecr.eu-west-2.amazonaws.com/core"

  prefix                                            = local.prefix
  app_host                                          = local.app_host
  app_task_desired_count                            = local.app_task_desired_count
  application_port                                  = local.application_port
  bulk_upload_bucket_details                        = data.terraform_remote_state.development_shared.outputs.bulk_upload_details
  cloudfront_header_name                            = data.terraform_remote_state.development_shared.outputs.front_door_cloudfront_header_name
  cloudfront_header_password                        = data.terraform_remote_state.development_shared.outputs.front_door_cloudfront_header_password
  database_name                                     = local.prefix
  database_partial_connection_string_parameter_name = data.terraform_remote_state.development_shared.outputs.database_rds_partial_connection_string_parameter_name
  ecs_deployment_role_name                          = data.terraform_remote_state.development_shared.outputs.application_roles_ecs_deployment_role_name
  ecs_security_group_id                             = data.terraform_remote_state.development_shared.outputs.application_security_group_ecs_security_group_id
  ecs_task_execution_role_arn                       = data.terraform_remote_state.development_shared.outputs.application_roles_ecs_task_execution_role_arn
  ecs_task_execution_role_id                        = data.terraform_remote_state.development_shared.outputs.application_roles_ecs_task_execution_role_id
  ecs_task_role_arn                                 = data.terraform_remote_state.development_shared.outputs.application_roles_ecs_task_role_arn
  export_bucket_details                             = data.terraform_remote_state.development_shared.outputs.cds_export_details
  govuk_notify_api_key_secret_arn                   = data.terraform_remote_state.development_shared.outputs.application_secrets_govuk_notify_api_key_secret_arn
  load_balancer_arn_suffix                          = data.terraform_remote_state.development_shared.outputs.front_door_load_balancer_arn_suffix
  load_balancer_listener_arn                        = data.terraform_remote_state.development_shared.outputs.front_door_load_balancer_listener_arn
  openai_api_key_secret_arn                         = data.terraform_remote_state.development_shared.outputs.application_secrets_openai_api_key_secret_arn
  os_data_key_secret_arn                            = data.terraform_remote_state.development_shared.outputs.application_secrets_os_data_key_secret_arn
  private_subnet_ids                                = data.terraform_remote_state.development_shared.outputs.networking_private_subnet_ids
  rails_env                                         = local.rails_env
  rails_master_key_secret_arn                       = data.terraform_remote_state.development_shared.outputs.application_secrets_rails_master_key_secret_arn
  redis_connection_string                           = module.redis.redis_connection_string
  relative_root                                     = "/${terraform.workspace}"
  review_app_user_password_secret_arn               = data.terraform_remote_state.development_shared.outputs.application_secrets_review_app_user_password_secret_arn
  sentry_dsn_secret_arn                             = data.terraform_remote_state.development_shared.outputs.application_secrets_sentry_dsn_secret_arn
  sns_topic_arn                                     = data.terraform_remote_state.development_shared.outputs.monitoring_sns_topic_arn
  suppress_missing_data_in_alarms                   = true
  staging_performance_test_email_secret_arn         = data.terraform_remote_state.development_shared.outputs.application_secrets_staging_performance_test_email_secret_arn
  staging_performance_test_password_secret_arn      = data.terraform_remote_state.development_shared.outputs.application_secrets_staging_performance_test_password_secret_arn
  suppress_ok_notifications                         = true
  vpc_id                                            = data.terraform_remote_state.development_shared.outputs.networking_vpc_id
}

module "redis" {
  source = "../../modules/elasticache"

  snapshot_retention_limit = 0 # no backups

  apply_changes_immediately = true
  highly_available          = false
  node_type                 = "cache.t4g.micro"

  prefix                  = local.prefix
  redis_port              = local.redis_port
  redis_security_group_id = data.terraform_remote_state.development_shared.outputs.application_security_group_redis_security_group_id
  redis_subnet_group_name = data.terraform_remote_state.development_shared.outputs.networking_redis_private_subnet_group_name
  skip_final_snapshot     = true
}
