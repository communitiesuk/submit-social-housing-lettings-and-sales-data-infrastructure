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
  alias  = "eu-west-1"
  region = "eu-west-1"

  assume_role {
    role_arn = local.provider_role_arn
  }
}

provider "aws" {
  alias  = "eu-west-3"
  region = "eu-west-3"

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
  prefix = "core-prod"

  rails_env = "production"

  default_database_name = "data_collector"

  app_host                  = "submit-social-housing-data.communities.gov.uk"
  load_balancer_domain_name = "lb.submit-social-housing-data.communities.gov.uk"

  provider_role_arn = "arn:aws:iam::977287343304:role/developer"

  app_task_desired_count = 4

  enable_aws_shield = true

  application_port = 8080
  database_port    = 5432
  redis_port       = 6379

  create_db_migration_infra = true
  create_s3_migration_infra = true
}

module "budget" {
  source = "../modules/budget"

  cost_limit = 775

  prefix                 = local.prefix
  notification_topic_arn = module.monitoring_topic_main.sns_topic_arn
}

module "application" {
  source = "../modules/application"

  app_task_cpu    = 1024
  app_task_memory = 2048

  sidekiq_task_cpu           = 1024
  sidekiq_task_desired_count = 2
  sidekiq_task_memory        = 8192

  out_of_hours_scale_down = {
    enabled = true
    timings = {
      workday_start = "0 7"
      workday_end   = "30 19"
    }
    scale_to = {
      app     = 2
      sidekiq = 2
    }
  }

  collection_rollover_redeploy_enabled = true

  ecr_repository_url = "815624722760.dkr.ecr.eu-west-2.amazonaws.com/core"

  prefix                                            = local.prefix
  app_host                                          = local.app_host
  app_task_desired_count                            = local.app_task_desired_count
  application_port                                  = local.application_port
  bulk_upload_bucket_details                        = module.bulk_upload.details
  cloudfront_header_name                            = module.front_door.cloudfront_header_name
  cloudfront_header_password                        = module.front_door.cloudfront_header_password
  collection_resources_bucket_details               = module.collection_resources.details
  database_name                                     = local.default_database_name
  database_partial_connection_string_parameter_name = module.database.rds_partial_connection_string_parameter_name
  ecs_deployment_role_name                          = module.application_roles.ecs_deployment_role_name
  ecs_security_group_id                             = module.application_security_group.ecs_security_group_id
  ecs_task_execution_role_arn                       = module.application_roles.ecs_task_execution_role_arn
  ecs_task_execution_role_id                        = module.application_roles.ecs_task_execution_role_id
  ecs_task_role_arn                                 = module.application_roles.ecs_task_role_arn
  export_bucket_details                             = module.cds_export.details
  govuk_notify_api_key_secret_arn                   = module.application_secrets.govuk_notify_api_key_secret_arn
  load_balancer_arn_suffix                          = module.front_door.load_balancer_arn_suffix
  load_balancer_listener_arn                        = module.front_door.load_balancer_listener_arn
  openai_api_key_secret_arn                         = module.application_secrets.openai_api_key_secret_arn
  os_data_key_secret_arn                            = module.application_secrets.os_data_key_secret_arn
  private_subnet_ids                                = module.networking.private_subnet_ids
  rails_env                                         = local.rails_env
  rails_master_key_secret_arn                       = module.application_secrets.rails_master_key_secret_arn
  review_app_user_password_secret_arn               = module.application_secrets.review_app_user_password_secret_arn
  redis_connection_string                           = module.redis.redis_connection_string
  sentry_dsn_secret_arn                             = module.application_secrets.sentry_dsn_secret_arn
  sns_topic_arn                                     = module.monitoring_topic_main.sns_topic_arn
  vpc_id                                            = module.networking.vpc_id

  depends_on = [module.database.rds_partial_connection_string_parameter_name]
}

module "application_roles" {
  source = "../modules/application_roles"

  github_actions_role_arn = "arn:aws:iam::815624722760:role/core-application-repo"

  prefix                                        = local.prefix
  bulk_upload_bucket_access_policy_arn          = module.bulk_upload.read_write_policy_arn
  collection_resources_bucket_access_policy_arn = module.collection_resources.read_write_policy_arn
  database_data_access_policy_arn               = module.database.rds_data_access_policy_arn
  export_bucket_access_policy_arn               = module.cds_export.read_write_policy_arn

  secret_arns = [
    module.application_secrets.govuk_notify_api_key_secret_arn,
    module.application_secrets.openai_api_key_secret_arn,
    module.application_secrets.os_data_key_secret_arn,
    module.application_secrets.rails_master_key_secret_arn,
    module.application_secrets.review_app_user_password_secret_arn,
    module.application_secrets.sentry_dsn_secret_arn
  ]
}

module "application_secrets" {
  source = "../modules/application_secrets"

  prefix                      = local.prefix
  ecs_task_execution_role_arn = module.application_roles.ecs_task_execution_role_arn
}

module "application_security_group" {
  source = "../modules/application_security_group"

  prefix                          = local.prefix
  application_port                = local.application_port
  database_port                   = local.database_port
  db_security_group_id            = module.database.rds_security_group_id
  load_balancer_security_group_id = module.front_door.load_balancer_security_group_id
  redis_port                      = local.redis_port
  vpc_id                          = module.networking.vpc_id
}

module "bulk_upload" {
  source = "../modules/bulk_upload"

  prefix            = local.prefix
  ecs_task_role_arn = module.application_roles.ecs_task_role_arn
}

module "cds_export" {
  source = "../modules/cds_export"

  prefix        = local.prefix
  bucket_suffix = "-cds"
  cds_access_role_arns = [
    "arn:aws:iam::062321884391:role/DSQL1",
    "arn:aws:iam::062321884391:role/DSQSS"
  ]
  ecs_task_role_arn = module.application_roles.ecs_task_role_arn
}

module "certificates" {
  source = "../modules/certificates"

  providers = {
    aws.us-east-1 = aws.us-east-1
  }

  cloudfront_domain_name    = local.app_host
  load_balancer_domain_name = local.load_balancer_domain_name
}

module "collection_resources" {
  source = "../modules/collection_resources"

  prefix = local.prefix
}

module "database" {
  source = "../modules/rds"

  allocated_storage       = 100
  backup_retention_period = 7

  apply_changes_immediately          = false
  create_replica                     = true
  enable_primary_deletion_protection = true
  enable_replica_deletion_protection = true
  multi_az                           = true
  skip_final_snapshot                = false
  instance_class                     = "db.t3.small"

  prefix = local.prefix

  database_port               = local.database_port
  db_subnet_group_name        = module.networking.db_private_subnet_group_name
  ecs_security_group_id       = module.application_security_group.ecs_security_group_id
  ecs_task_execution_role_arn = module.application_roles.ecs_task_execution_role_arn
  sns_topic_arn               = module.monitoring_topic_main.sns_topic_arn
  vpc_id                      = module.networking.vpc_id
}

module "database_migration" {
  source = "../modules/rds_migration"

  count = local.create_db_migration_infra ? 1 : 0

  db_migration_task_cpu      = 4096
  db_migration_task_memory   = 16384
  ecs_task_ephemeral_storage = 200 #GiB

  ecr_repository_url = "815624722760.dkr.ecr.eu-west-2.amazonaws.com/db-migration"

  cloudfoundry_service = "dluhc-core-production-postgres"
  cloudfoundry_space   = "production"

  prefix                                  = local.prefix
  database_complete_connection_string_arn = module.application.rds_complete_connection_string_arn
  database_port                           = local.database_port
  db_security_group_id                    = module.database.rds_security_group_id
  ecs_task_role_arn                       = module.application_roles.ecs_task_role_arn
  ecs_task_execution_role_arn             = module.application_roles.ecs_task_execution_role_arn
  ecs_task_execution_role_id              = module.application_roles.ecs_task_execution_role_id
  vpc_id                                  = module.networking.vpc_id
}

module "s3_migration" {
  source = "../modules/s3_migration"

  count = local.create_s3_migration_infra ? 1 : 0

  ecr_repository_url = "815624722760.dkr.ecr.eu-west-2.amazonaws.com/s3-migration"

  prefix = local.prefix
  buckets = {
    export = {
      source      = "s3://paas-s3-broker-prod-lon-b4f97132-daa8-4e37-b675-4a05dad7a9f4",
      destination = "s3://${module.cds_export.details.bucket_name}",
      policy_arn  = module.cds_export.read_write_policy_arn
    },
    csv = {
      source      = "s3://paas-s3-broker-prod-lon-1b5cddc8-08d8-45fa-8246-9a6ad5acdfb9",
      destination = "s3://${module.bulk_upload.details.bucket_name}",
      policy_arn  = module.bulk_upload.read_write_policy_arn
    }
  }

  vpc_id = module.networking.vpc_id
}

module "front_door" {
  source = "../modules/front_door"

  providers = {
    aws.us-east-1 = aws.us-east-1
  }

  restrict_by_geolocation = false

  prefix                        = local.prefix
  alarm_topic_arn               = module.monitoring_topic_us_east_1.sns_topic_arn
  application_port              = local.application_port
  cloudfront_certificate_arn    = module.certificates.cloudfront_certificate_arn
  cloudfront_domain_name        = local.app_host
  ecs_security_group_id         = module.application_security_group.ecs_security_group_id
  enable_aws_shield             = local.enable_aws_shield
  load_balancer_certificate_arn = module.certificates.load_balancer_certificate_arn
  load_balancer_domain_name     = local.load_balancer_domain_name
  public_subnet_ids             = module.networking.public_subnet_ids
  vpc_id                        = module.networking.vpc_id

  initial_create = var.initial_create
}

module "networking" {
  source = "../modules/networking"

  providers = {
    aws.eu-west-1 = aws.eu-west-1
    aws.eu-west-3 = aws.eu-west-3
    aws.us-east-1 = aws.us-east-1
  }

  prefix                                  = local.prefix
  vpc_cidr_block                          = "10.0.0.0/16"
  vpc_flow_cloudwatch_log_expiration_days = 60
}

module "monitoring_secrets" {
  source = "../modules/monitoring_secrets"

  prefix = local.prefix

  initial_create = var.initial_create
}

module "monitoring_topic_main" {
  source = "../modules/monitoring_topic"

  create_email_subscription = false

  create_lambda_subscription = true
  lambda_subscription_arn    = module.monitoring_slack_alerts.lambda_function_arn


  prefix                                = local.prefix
  service_identifiers_publishing_to_sns = ["cloudwatch.amazonaws.com", "budgets.amazonaws.com"]
}

module "monitoring_topic_us_east_1" {
  source = "../modules/monitoring_topic"

  providers = {
    aws = aws.us-east-1
  }

  create_email_subscription = false

  create_lambda_subscription = true
  lambda_subscription_arn    = module.monitoring_slack_alerts.lambda_function_arn

  prefix                                = local.prefix
  service_identifiers_publishing_to_sns = ["cloudwatch.amazonaws.com"]
}

module "monitoring_slack_alerts" {
  source = "../modules/slack_alert_lambda"

  environment = "Production"

  dead_letter_monitoring_email = module.monitoring_secrets.email_for_subscriptions
  monitoring_topics            = [module.monitoring_topic_main.sns_topic_arn, module.monitoring_topic_us_east_1.sns_topic_arn]
  prefix                       = local.prefix
  slack_webhook_url            = module.monitoring_secrets.slack_webhook_for_subscriptions
}

module "redis" {
  source = "../modules/elasticache"

  snapshot_retention_limit = 5

  apply_changes_immediately = false
  highly_available          = true
  node_type                 = "cache.t4g.micro"

  notification_topic_arn = module.monitoring_topic_main.sns_topic_arn

  prefix                  = local.prefix
  redis_port              = local.redis_port
  redis_security_group_id = module.application_security_group.redis_security_group_id
  redis_subnet_group_name = module.networking.redis_private_subnet_group_name
}
