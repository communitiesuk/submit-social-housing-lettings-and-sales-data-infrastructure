terraform {
  required_version = "~>1.5.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
      configuration_aliases = [aws.us-east-1]
    }
    random = {
      version = "~>3.5"
      source  = "hashicorp/random"
    }
  }
}
