terraform {
  required_version = "~>1.5.1"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~>5.0"
      configuration_aliases = [aws.eu-west-1]
    }
  }
}

locals {
  prefix = "${var.prefix}-tf-state"
}