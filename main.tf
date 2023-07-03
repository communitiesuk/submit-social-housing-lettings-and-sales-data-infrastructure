terraform {
    required_providers {
      aws = {
        version = "~>5.0"
        source = "hashicorp/aws"
      }
    }
}

provider "aws" {
    region = var.region
}

# You cannot create a new backend by simply defining this and then
# immediately proceeding to "terraform apply". The S3 backend must
# be bootstrapped according to the simple yet essential procedure in
# https://github.com/cloudposse/terraform-aws-tfstate-backend#usage
module "terraform_state_backend" {
  source = "cloudposse/tfstate-backend/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version     = "1.1.1"
  namespace  = "core"
  stage      = "dev"
  name       = "terraform"
  attributes = ["state"]

  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend.tf"
  force_destroy                      = false
}
