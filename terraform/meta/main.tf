terraform {
  required_version = "~>1.5.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }

  backend "s3" {
    bucket         = "core-prod-tf-state"
    dynamodb_table = "core-prod-tf-state-lock"
    encrypt        = true
    key            = "core-meta.tfstate"
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

locals {
  prefix = "core-meta"

  provider_role_arn = "arn:aws:iam::815624722760:role/developer"

  create_db_migration_infra = true
  create_s3_migration_infra = true
}

# We create two backends for managing the terraform state of different accounts:
# non_prod manages meta, development and staging
# prod manages just production
module "non_prod_backend" {
  source = "../modules/backend"

  providers = {
    aws.eu-west-1 = aws.eu-west-1
  }

  prefix = "core-non-prod"
}

module "prod_backend" {
  source = "../modules/backend"

  providers = {
    aws.eu-west-1 = aws.eu-west-1
  }

  prefix = "core-prod"
}

module "ecr" {
  source = "../modules/ecr"

  allow_access_by_roles = [
    "arn:aws:iam::837698168072:role/core-dev-task-execution",
    "arn:aws:iam::107155005276:role/core-staging-task-execution",
    "arn:aws:iam::977287343304:role/core-prod-task-execution"
  ]
  sns_topic_arn = module.monitoring.sns_topic_arn
}

module "ecr_rds_migration" {
  source = "../modules/ecr_migration"

  count = local.create_db_migration_infra ? 1 : 0

  # This will need updating to include dev and production roles
  allow_access_by_roles = [
    "arn:aws:iam::107155005276:role/core-staging-task-execution",
    "arn:aws:iam::977287343304:role/core-prod-task-execution"
  ]
  repository_name = "db-migration"
}

module "ecr_s3_migration" {
  source = "../modules/ecr_migration"

  count = local.create_s3_migration_infra ? 1 : 0

  # This will need manual updating for prod environment
  allow_access_by_roles = [
    "arn:aws:iam::107155005276:role/core-staging-csv-s3-migration-task-execution",
    "arn:aws:iam::107155005276:role/core-staging-export-s3-migration-task-execution",
    "arn:aws:iam::977287343304:role/core-prod-csv-s3-migration-task-execution",
    "arn:aws:iam::977287343304:role/core-prod-export-s3-migration-task-execution"
  ]
  repository_name = "s3-migration"
}

module "monitoring" {
  source = "../modules/monitoring"

  create_email_subscription = true

  prefix                               = local.prefix
  service_identifier_publishing_to_sns = "events.amazonaws.com"

  create_secrets_first = var.create_secrets_first
}

data "aws_caller_identity" "current" {}

module "github_actions_access" {
  source = "../modules/github_actions_access"

  meta_account_id = data.aws_caller_identity.current.account_id
  repositories = {
    application = {
      name = "communitiesuk/submit-social-housing-lettings-and-sales-data",
      policies = [
        { key = "push_ecr_images", arn = module.ecr.push_images_policy_arn },
        { key = "access_non_prod_state", arn = module.non_prod_backend.state_access_policy_arn }
      ]
    },
    infrastructure = {
      name     = "communitiesuk/submit-social-housing-lettings-and-sales-data-infrastructure"
      policies = []
    }
  }
}

moved {
  from = module.github_actions_access.aws_iam_policy.state_access
  to   = module.non_prod_backend.aws_iam_policy.state_access
}

moved {
  from = module.github_actions_access.aws_iam_policy.push_images
  to   = module.ecr.aws_iam_policy.push_images
}

moved {
  from = module.github_actions_access.aws_iam_role_policy_attachment.app_repo_push_images
  to   = module.github_actions_access.aws_iam_role_policy_attachment.attach_policies["application_push_ecr_images"]
}

moved {
  from = module.github_actions_access.aws_iam_role_policy_attachment.app_repo_state_access
  to   = module.github_actions_access.aws_iam_role_policy_attachment.attach_policies["application_access_non_prod_state"]
}