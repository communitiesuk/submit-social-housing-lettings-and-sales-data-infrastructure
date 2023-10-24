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
  prefix = "core-prod"

  rails_env = "production"

  default_database_name = "data_collector"

  app_host                  = "submit-social-housing-data.levellingup.gov.uk"
  load_balancer_domain_name = "lb.submit-social-housing-data.levellingup.gov.uk"

  provider_role_arn = "arn:aws:iam::977287343304:role/developer"

  app_task_desired_count = 4

  enable_aws_shield = false

  application_port = 8080
  database_port    = 5432
  redis_port       = 6379

  create_db_migration_infra = false
}

moved {
  from = module.application.aws_iam_policy.ecs_tasks_and_services
  to   = module.application.aws_iam_policy.run_ecs_task_and_update_service
}

moved {
  from = module.application.aws_iam_role_policy_attachment.ecs_tasks_and_services
  to   = module.application.aws_iam_role_policy_attachment.run_ecs_task_and_update_service
}

moved {
  from = module.front_door.aws_lb_target_group.this
  to   = module.application.aws_lb_target_group.this
}

moved {
  from = module.front_door.aws_lb_listener_rule.forward_cloudfront
  to   = module.application.aws_lb_listener_rule.forward_cloudfront
}

moved {
  from = module.front_door.aws_cloudwatch_metric_alarm.healthy_hosts_count
  to   = module.application.aws_cloudwatch_metric_alarm.healthy_hosts_count
}

moved {
  from = module.front_door.aws_cloudwatch_metric_alarm.unhealthy_hosts_count
  to   = module.application.aws_cloudwatch_metric_alarm.unhealthy_hosts_count
}

moved {
  from = module.application_roles.aws_iam_role_policy.parameter_access
  to   = module.application.aws_iam_role_policy.parameter_access
}

module "application" {
  source = "../modules/application"

  app_task_cpu    = 512
  app_task_memory = 1024

  sidekiq_task_cpu           = 1024
  sidekiq_task_desired_count = 2
  sidekiq_task_memory        = 8192

  ecr_repository_url = "815624722760.dkr.ecr.eu-west-2.amazonaws.com/core"

  prefix                                            = local.prefix
  api_key_secret_arn                                = module.application_secrets.api_key_secret_arn
  app_host                                          = local.app_host
  app_task_desired_count                            = local.app_task_desired_count
  application_port                                  = local.application_port
  bulk_upload_bucket_details                        = module.bulk_upload.details
  cloudfront_header_name                            = module.front_door.cloudfront_header_name
  cloudfront_header_password                        = module.front_door.cloudfront_header_password
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
  os_data_key_secret_arn                            = module.application_secrets.os_data_key_secret_arn
  private_subnet_ids                                = module.networking.private_subnet_ids
  rails_env                                         = local.rails_env
  rails_master_key_secret_arn                       = module.application_secrets.rails_master_key_secret_arn
  redis_connection_string                           = module.redis.redis_connection_string
  sentry_dsn_secret_arn                             = module.application_secrets.sentry_dsn_secret_arn
  sns_topic_arn                                     = module.monitoring.sns_topic_arn
  vpc_id                                            = module.networking.vpc_id
}

moved {
  from = module.application.aws_iam_role.task
  to   = module.application_roles.aws_iam_role.task
}

moved {
  from = module.application.aws_iam_role_policy_attachment.ecs_task_database_data_access
  to   = module.application_roles.aws_iam_role_policy_attachment.ecs_task_database_data_access
}

moved {
  from = module.application.aws_iam_role_policy_attachment.ecs_task_redis_access
  to   = module.application_roles.aws_iam_role_policy_attachment.ecs_task_redis_access
}

moved {
  from = module.application.aws_iam_role_policy.cloudwatch_logs_access
  to   = module.application_roles.aws_iam_role_policy.cloudwatch_logs_access
}

moved {
  from = module.application.aws_iam_policy.allow_ecs_exec
  to   = module.application_roles.aws_iam_policy.allow_ecs_exec
}

moved {
  from = module.application.aws_iam_role_policy_attachment.task_allow_ecs_exec
  to   = module.application_roles.aws_iam_role_policy_attachment.task_allow_ecs_exec
}

moved {
  from = module.application.aws_iam_role_policy_attachment.task_bulk_upload_bucket_access
  to   = module.application_roles.aws_iam_role_policy_attachment.task_bulk_upload_bucket_access
}

moved {
  from = module.application.aws_iam_role_policy_attachment.task_export_bucket_access
  to   = module.application_roles.aws_iam_role_policy_attachment.task_export_bucket_access
}

moved {
  from = module.application.aws_iam_role.task_execution
  to   = module.application_roles.aws_iam_role.task_execution
}

moved {
  from = module.application.aws_iam_role_policy_attachment.task_execution_managed_policy
  to   = module.application_roles.aws_iam_role_policy_attachment.task_execution_managed_policy
}

moved {
  from = module.application.aws_iam_role_policy.parameter_access
  to   = module.application_roles.aws_iam_role_policy.parameter_access
}

moved {
  from = module.application.aws_iam_role_policy.secret_access
  to   = module.application_roles.aws_iam_role_policy.secret_access
}


module "application_roles" {
  source = "../modules/application_roles"

  github_actions_role_arn = "arn:aws:iam::815624722760:role/core-application-repo"

  prefix                               = local.prefix
  bulk_upload_bucket_access_policy_arn = module.bulk_upload.read_write_policy_arn
  database_data_access_policy_arn      = module.database.rds_data_access_policy_arn
  export_bucket_access_policy_arn      = module.cds_export.read_write_policy_arn

  secret_arns = [
    module.application_secrets.api_key_secret_arn,
    module.application_secrets.govuk_notify_api_key_secret_arn,
    module.application_secrets.os_data_key_secret_arn,
    module.application_secrets.rails_master_key_secret_arn,
    module.application_secrets.sentry_dsn_secret_arn
  ]
}

moved {
  from = module.application.aws_secretsmanager_secret.api_key
  to   = module.application_secrets.aws_secretsmanager_secret.api_key
}

moved {
  from = module.application.aws_secretsmanager_secret.govuk_notify_api_key
  to   = module.application_secrets.aws_secretsmanager_secret.govuk_notify_api_key
}

moved {
  from = module.application.aws_secretsmanager_secret.os_data_key
  to   = module.application_secrets.aws_secretsmanager_secret.os_data_key
}

moved {
  from = module.application.aws_secretsmanager_secret.rails_master_key
  to   = module.application_secrets.aws_secretsmanager_secret.rails_master_key
}

moved {
  from = module.application.aws_secretsmanager_secret.sentry_dsn
  to   = module.application_secrets.aws_secretsmanager_secret.sentry_dsn
}

moved {
  from = module.redis.aws_security_group.this
  to   = module.application_security_group.aws_security_group.redis
}

moved {
  from = module.redis.aws_vpc_security_group_ingress_rule.redis_ingress
  to   = module.application_security_group.aws_vpc_security_group_ingress_rule.redis_ingress
}

module "application_secrets" {
  source = "../modules/application_secrets"
}

moved {
  from = module.redis.aws_security_group.this
  to   = module.application_roles.aws_security_group.redis
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

moved {
  from = module.bulk_upload.aws_s3_bucket.this
  to   = module.bulk_upload.aws_s3_bucket.bulk_upload
}

moved {
  from = module.bulk_upload.aws_s3_bucket_public_access_block.this
  to   = module.bulk_upload.aws_s3_bucket_public_access_block.bulk_upload
}

moved {
  from = module.bulk_upload.aws_s3_bucket_lifecycle_configuration.this
  to   = module.bulk_upload.aws_s3_bucket_lifecycle_configuration.bulk_upload
}

module "bulk_upload" {
  source = "../modules/bulk_upload"

  prefix = local.prefix
}

moved {
  from = module.cds_export.aws_s3_bucket.this
  to   = module.cds_export.aws_s3_bucket.export
}

moved {
  from = module.cds_export.aws_s3_bucket_public_access_block.this
  to   = module.cds_export.aws_s3_bucket_public_access_block.export
}

moved {
  from = module.cds_export.aws_s3_bucket_lifecycle_configuration.this
  to   = module.cds_export.aws_s3_bucket_lifecycle_configuration.export
}

module "cds_export" {
  source = "../modules/cds_export"

  prefix        = local.prefix
  bucket_suffix = "-cds"
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

moved {
  from = module.database.aws_ssm_parameter.database_connection_string
  to   = module.database.aws_ssm_parameter.database_partial_connection_string
}

module "database" {
  source = "../modules/rds"

  allocated_storage         = 100
  apply_changes_immediately = false
  backup_retention_period   = 7
  highly_available          = true
  instance_class            = "db.t3.small"

  prefix = local.prefix

  database_port         = local.database_port
  db_subnet_group_name  = module.networking.db_private_subnet_group_name
  ecs_security_group_id = module.application_security_group.ecs_security_group_id
  sns_topic_arn         = module.monitoring.sns_topic_arn
  vpc_id                = module.networking.vpc_id
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

module "front_door" {
  source = "../modules/front_door"

  providers = {
    aws.us-east-1 = aws.us-east-1
  }

  restrict_by_ip = false

  prefix                        = local.prefix
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

  prefix                                  = local.prefix
  vpc_cidr_block                          = "10.0.0.0/16"
  vpc_flow_cloudwatch_log_expiration_days = 60
}

moved {
  from = module.networking.aws_vpc.this
  to   = module.networking.aws_vpc.main
}

module "monitoring" {
  source = "../modules/monitoring"

  prefix                               = local.prefix
  service_identifier_publishing_to_sns = "cloudwatch.amazonaws.com"
}

module "redis" {
  source = "../modules/elasticache"

  apply_changes_immediately = false
  highly_available          = true
  node_type                 = "cache.t4g.micro"

  prefix                  = local.prefix
  redis_port              = local.redis_port
  redis_security_group_id = module.application_security_group.redis_security_group_id
  redis_subnet_group_name = module.networking.redis_private_subnet_group_name
}
