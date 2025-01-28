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

  app_host                  = "review.submit-social-housing-data.communities.gov.uk"
  load_balancer_domain_name = "review.lb.submit-social-housing-data.communities.gov.uk"
  # all the review apps will be in this test subdomain (nothing to do with automated tests etc.)
  test_app_host = "test.submit-social-housing-data.communities.gov.uk"

  provider_role_arn = "arn:aws:iam::837698168072:role/developer"

  enable_aws_shield = false

  application_port = 8080
  database_port    = 5432
  redis_port       = 6379
}

module "budget" {
  source = "../../modules/budget"

  cost_limit = 800

  prefix                 = local.prefix
  notification_topic_arn = module.monitoring_topic_main.sns_topic_arn
}

module "application_roles" {
  source = "../../modules/application_roles"

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
    module.application_secrets.sentry_dsn_secret_arn,
    module.application_secrets.staging_performance_test_email_secret_arn,
    module.application_secrets.staging_performance_test_password_secret_arn
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

module "collection_resources" {
  source = "../../modules/collection_resources"

  prefix = local.prefix
}

module "database" {
  source = "../../modules/rds"

  allocated_storage       = 50
  backup_retention_period = 0 # no backups

  apply_changes_immediately          = true
  enable_primary_deletion_protection = true
  multi_az                           = false
  skip_final_snapshot                = true
  instance_class                     = "db.t4g.small"

  scheduled_stop = {
    enabled = true
    timings = {
      workday_start = "30 7"
      workday_end   = "0 20"
    }
  }
  maintenance_window = "Mon:18:00-Mon:18:30"

  prefix = local.prefix

  database_port               = local.database_port
  db_subnet_group_name        = module.networking.db_private_subnet_group_name
  ecs_security_group_id       = module.application_security_group.ecs_security_group_id
  ecs_task_execution_role_arn = module.application_roles.ecs_task_execution_role_arn
  sns_topic_arn               = module.monitoring_topic_main.sns_topic_arn
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

  restrict_by_geolocation = true

  prefix                        = local.prefix
  alarm_topic_arn               = module.monitoring_topic_us_east_1.sns_topic_arn
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

module "monitoring_secrets" {
  source = "../../modules/monitoring_secrets"

  prefix = local.prefix

  initial_create = var.initial_create
}

module "monitoring_topic_main" {
  source = "../../modules/monitoring_topic"

  create_email_subscription = true

  email_subscription_endpoint           = module.monitoring_secrets.email_for_subscriptions
  prefix                                = local.prefix
  service_identifiers_publishing_to_sns = ["cloudwatch.amazonaws.com", "budgets.amazonaws.com"]
}

module "monitoring_topic_us_east_1" {
  source = "../../modules/monitoring_topic"

  providers = {
    aws = aws.us-east-1
  }

  create_email_subscription = true

  email_subscription_endpoint           = module.monitoring_secrets.email_for_subscriptions
  prefix                                = local.prefix
  service_identifiers_publishing_to_sns = ["cloudwatch.amazonaws.com"]
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

resource "aws_cloudwatch_log_group" "test_zone_log_group" {
  #checkov:skip=CKV_AWS_158:leaving this out for the timebeing
  #checkov:skip=CKV_AWS_338:minimum log retention of at least 1 year is excessive and are ok with less
  name              = "/aws/route53/${aws_route53_zone.test_zone.name}"
  retention_in_days = 30
}

data "aws_iam_policy_document" "test_zone_query_logging_policy_document" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:log-group:/aws/route53/*"]

    principals {
      identifiers = ["route53.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "test_zone_query_logging_policy" {
  policy_document = data.aws_iam_policy_document.test_zone_query_logging_policy_document.json
  policy_name     = "test_zone_query_logging_policy"
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "dnssec_kms_key" {
  description              = "KMS key used to create key-signing key (KSK) for Route53."
  customer_master_key_spec = "ECC_NIST_P256"
  key_usage                = "SIGN_VERIFY"
}

resource "aws_kms_key_policy" "dnssec_policy" {
  key_id = aws_kms_key.dnssec_kms_key.id
  policy = data.aws_iam_policy_document.dnssec_policy_document.json
}

data "aws_iam_policy_document" "dnssec_policy_document" {
  statement {
    sid = "AllowRoute53DNSSECService"

    actions = [
      "kms:DescribeKey",
      "kms:GetPublicKey",
      "kms:Sign",
      "kms:Verify"
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["dnssec-route53.amazonaws.com"]
    }

    resources = [aws_kms_key.dnssec_kms_key.arn]
  }

  statement {
    sid = "EnableIAMUserPermissions"

    actions = [
      "kms:*"
    ]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    resources = [aws_kms_key.dnssec_kms_key.arn]
  }
}

resource "aws_route53_zone" "test_zone" {
  name = local.test_app_host
}

resource "aws_route53_query_log" "test_zone_query_log" {
  depends_on = [aws_cloudwatch_log_resource_policy.test_zone_query_logging_policy]

  cloudwatch_log_group_arn = aws_cloudwatch_log_group.test_zone_log_group.arn
  zone_id                  = aws_route53_zone.test_zone.zone_id
}

resource "aws_route53_key_signing_key" "test_zone_ksk" {
  hosted_zone_id             = aws_route53_zone.test_zone.id
  key_management_service_arn = aws_kms_key.dnssec_kms_key.arn
  name                       = "test_zone_ksk"
}

resource "aws_route53_hosted_zone_dnssec" "test_zone_dnssec" {
  depends_on = [
    aws_route53_key_signing_key.test_zone_ksk
  ]
  hosted_zone_id = aws_route53_key_signing_key.test_zone_ksk.hosted_zone_id
}
