terraform {
  required_providers {
    aws = {
      version = "~>5.0"
      source  = "hashicorp/aws"
    }
  }

  # TODO - uncomment once backend has been created by the cloudposse module below.
  # TODO - update bucket and dynamodb_table names with info in the backend_non_production.tf file it produces
   backend "s3" {
     region         = "eu-west-2"
     bucket         = "core-non-production-terraform-states"
     key            = "core-meta.tfstate"
     dynamodb_table = "core-non-production-terraform-states-lock"
     encrypt        = true
     role_arn       = "arn:aws:iam::META-ACCOUNT-ID:role/ROLE-NAME"
   }
}

provider "aws" {
  region = "eu-west-2"
}

# We create two backends. One for the meta, development and staging accounts, and one just for production
# You cannot create a new backend by simply defining this and then immediately proceeding to "terraform apply".
# The S3 backend must be bootstrapped according to the simple yet essential procedure in:
# https://github.com/cloudposse/terraform-aws-tfstate-backend#usage

module "terraform_state_backend_non_production" {
  source = "cloudposse/tfstate-backend/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version    = "1.1.1"
  namespace  = "core"
  stage      = "non-production"
  name       = "terraform"
  attributes = ["states"]

  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend_non_production.tf"
  force_destroy                      = false
}

module "terraform_state_backend_production" {
  source = "cloudposse/tfstate-backend/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version    = "1.1.1"
  namespace  = "core"
  stage      = "production"
  name       = "terraform"
  attributes = ["state"]

  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend_production.tf"
  force_destroy                      = false
}
