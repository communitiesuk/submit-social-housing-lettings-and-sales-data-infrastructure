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
    key            = "core-development-shared.tfstate"
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
  prefix = "core-dev"

  app_host                  = "review.submit-social-housing-data.levellingup.gov.uk"
  load_balancer_domain_name = "review.lb.submit-social-housing-data.levellingup.gov.uk"

  provider_role_arn = "arn:aws:iam::837698168072:role/developer"

  enable_aws_shield = false

  application_port = 8080
  database_port    = 5432
  redis_port       = 6379
}

module "application_roles" {
  source = "../../modules/application_roles"

  github_actions_role_arn = "arn:aws:iam::815624722760:role/core-application-repo"

  prefix                               = local.prefix
  bulk_upload_bucket_access_policy_arn = module.bulk_upload.read_write_policy_arn
  database_data_access_policy_arn      = module.database.rds_data_access_policy_arn
  export_bucket_access_policy_arn      = module.cds_export.read_write_policy_arn

  secret_arns = [
    module.application_secrets.govuk_notify_api_key_secret_arn,
    module.application_secrets.os_data_key_secret_arn,
    module.application_secrets.rails_master_key_secret_arn,
    module.application_secrets.sentry_dsn_secret_arn
  ]
}

module "application_secrets" {
  source = "../../modules/application_secrets"

  prefix                      = local.prefix
  ecs_task_execution_role_arn = module.application_roles.ecs_task_execution_role_arn
}

module "application_security_group" {
  source = "../../modules/application_security_group"

  prefix                          = local.prefix
  application_port                = local.application_port
  database_port                   = local.database_port
  db_security_group_id            = module.database.rds_security_group_id
  load_balancer_security_group_id = module.front_door.load_balancer_security_group_id
  redis_port                      = local.redis_port
  vpc_id                          = module.networking.vpc_id
}

module "bulk_upload" {
  source = "../../modules/bulk_upload"

  prefix            = local.prefix
  ecs_task_role_arn = module.application_roles.ecs_task_role_arn
}

module "cds_export" {
  source = "../../modules/cds_export"

  prefix            = local.prefix
  ecs_task_role_arn = module.application_roles.ecs_task_role_arn
}

module "certificates" {
  source = "../../modules/certificates"

  providers = {
    aws.us-east-1 = aws.us-east-1
  }

  cloudfront_domain_name    = local.app_host
  load_balancer_domain_name = local.load_balancer_domain_name
}

module "database" {
  source = "../../modules/rds"

  allocated_storage       = 50
  backup_retention_period = 0 # no backups

  apply_changes_immediately          = true
  enable_primary_deletion_protection = true
  enable_replica_deletion_protection = true
  highly_available                   = false
  skip_final_snapshot                = true
  instance_class                     = "db.m5.xlarge"

  prefix = local.prefix

  database_port               = local.database_port
  db_subnet_group_name        = module.networking.db_private_subnet_group_name
  ecs_security_group_id       = module.application_security_group.ecs_security_group_id
  ecs_task_execution_role_arn = module.application_roles.ecs_task_execution_role_arn
  sns_topic_arn               = module.monitoring.sns_topic_arn
  vpc_id                      = module.networking.vpc_id
}

module "deployment_role" {
  source = "../../modules/terraform_deployment"

  prefix = local.prefix
  assume_from_role_arns = [
    "arn:aws:iam::815624722760:role/developer",
    "arn:aws:iam::815624722760:role/core-application-repo"
  ]
}

module "front_door" {
  source = "../../modules/front_door"

  providers = {
    aws.us-east-1 = aws.us-east-1
  }

  restrict_by_ip = true

  prefix                        = local.prefix
  append_suffix_to_bucket_names = ["load-balancer-logs"]
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

module "monitoring" {
  source = "../../modules/monitoring"

  create_email_subscription = false

  prefix                               = local.prefix
  service_identifier_publishing_to_sns = "cloudwatch.amazonaws.com"

  create_secrets_first = var.create_secrets_first
}

module "networking" {
  source = "../../modules/networking"

  providers = {
    aws.eu-west-1 = aws.eu-west-1
    aws.eu-west-3 = aws.eu-west-3
    aws.us-east-1 = aws.us-east-1
  }

  prefix                                  = local.prefix
  vpc_cidr_block                          = "10.0.0.0/16"
  vpc_flow_cloudwatch_log_expiration_days = 60
}

moved {
  from = module.networking.aws_vpc.this
  to   = module.networking.aws_vpc.main
}
