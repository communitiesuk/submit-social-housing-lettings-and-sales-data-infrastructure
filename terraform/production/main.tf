terraform {
  required_providers {
    aws = {
      version = "~>5.0"
      source  = "hashicorp/aws"
    }
  }

  # TODO - update with correct PRODUCTION bucket and dynamodb-table once backend made using cloudposse module in meta/main.tf
  backend "s3" {
    region          = "eu-west-2"
    bucket          = "core-production-terraform-state"
    key             = "core-production.tfstate"
    dynamodb_table = "core-production-terraform-state-lock"
    encrypt         = true
    role_arn        = "arn:aws:iam::815624722760:role/developer"
  }
}

provider "aws" {
  region = "eu-west-2"

  # TODO - update with account id and role name to assume once created by DLUHC
  assume_role {
    role_arn = "arn:aws:iam::977287343304:role/developer"
  }
}