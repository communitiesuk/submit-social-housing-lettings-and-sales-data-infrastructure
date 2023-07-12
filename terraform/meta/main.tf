terraform {
  required_version = "~>1.5.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }

  backend "s3" {
    bucket         = "core-non-prod-tf-state"
    dynamodb_table = "core-non-prod-tf-state-lock"
    encrypt        = true
    key            = "core-meta.tfstate"
    region         = "eu-west-2"
    role_arn       = "arn:aws:iam::META-ACCOUNT-ID:role/ROLE-NAME"
  }
}

provider "aws" {
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::META-ACCOUNT-ID:role/ROLE-NAME"
  }
}

# We create two backends. non_prod manages terraform state for the meta, development and staging accounts, and prod just
# for production
module "non_prod_backend" {
  source = "../modules/backend"

  state_bucket_name             = "core-non-prod-tf-state"
  state_lock_dynamodb_name      = "core-non-prod-tf-state-lock"
  state_log_bucket_name         = "core-non-prod-tf-state-logs"
  state_replication_bucket_name = "core-non-prod-tf-state-replication"
}

module "prod_backend" {
  source = "../modules/backend"

  state_bucket_name             = "core-prod-tf-state"
  state_lock_dynamodb_name      = "core-prod-tf-state-lock"
  state_log_bucket_name         = "core-prod-tf-state-logs"
  state_replication_bucket_name = "core-prod-tf-state-replication"
}