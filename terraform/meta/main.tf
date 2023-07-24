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
}