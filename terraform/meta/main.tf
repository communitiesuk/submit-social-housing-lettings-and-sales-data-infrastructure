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
    role_arn = "arn:aws:iam::815624722760:role/developer"
  }
}

# We create two backends for managing the terraform state of different accounts:
# non_prod manages meta, development and staging
# prod manages just production
module "non_prod_backend" {
  source = "../modules/backend"

  prefix = "core-non-prod"
}

module "prod_backend" {
  source = "../modules/backend"

  prefix = "core-prod"
}

module "ecr" {
  source = "../modules/ecr"

  # This will need updating to include dev and production roles
  allow_access_by_roles = ["arn:aws:iam::107155005276:role/core-stag-task-execution"]
}

data "aws_caller_identity" "current" {}

module "github_actions_access" {
  source = "../modules/github_actions_access"

  application_repo = "communitiesuk/submit-social-housing-lettings-and-sales-data"
  ecr_arn          = module.ecr.repository_arn
  meta_account_id  = data.aws_caller_identity.current.account_id
}