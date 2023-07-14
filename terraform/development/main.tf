terraform {
  required_version = "~>1.5.1"

  required_providers {
    aws = {
      version = "~>5.0"
      source  = "hashicorp/aws"
    }
  }

  # TODO - update with correct NON-production bucket and dynamodb-table once backend made using cloudposse module in meta/main.tf
  backend "s3" {
    bucket         = "core-non-prod-tf-state"
    dynamodb_table = "core-non-prod-tf-state-lock"
    encrypt        = true
    key            = "core-development.tfstate"
    region         = "eu-west-2"
    role_arn       = "arn:aws:iam::815624722760:role/developer"
  }
}

provider "aws" {
  region = "eu-west-2"

  # TODO - update with account id and role name to assume once created by DLUHC
  assume_role {
    role_arn = "arn:aws:iam::837698168072:role/developer"
  }
}
