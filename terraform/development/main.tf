terraform {
  required_providers {
    aws = {
      version = "~>5.0"
      source  = "hashicorp/aws"
    }
  }

  # TODO - update with correct NON-production bucket and dynamodb-table once backend made using cloudposse module in meta/main.tf
  backend "s3" {
    region          = "eu-west-2"
    bucket          = "core-non-production-terraform-states"
    key             = "core-development.tfstate"
    dyanamodb_table = "core-non-production-terraform-states-lock"
    encrypt         = true
  }
}

provider "aws" {
  region = "eu-west-2"

  # TODO - update with account id and role name to assume once created by DLUHC
  assume_role {
    role_arn = "arn:aws:iam::DEVELOPMENT-ACCOUNT-ID:role/ROLE-NAME"
  }
}
