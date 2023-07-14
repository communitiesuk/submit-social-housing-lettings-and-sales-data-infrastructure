terraform {
  required_providers {
    aws = {
      version = "~>5.0"
      source  = "hashicorp/aws"
    }
  }

  # TODO - update with correct PRODUCTION bucket and dynamodb-table once backend made using cloudposse module in meta/main.tf
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

  # TODO - update with account id and role name to assume once created by DLUHC
  assume_role {
    role_arn = "arn:aws:iam::977287343304:role/developer"
  }
}