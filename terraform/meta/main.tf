terraform {
  required_providers {
    aws = {
      version = "~>5.0"
      source  = "hashicorp/aws"
    }
  }

  # TODO - uncomment once backend has been created by the cloudposse module below.
  # TODO - update bucket and dynamodb_table names with info in the backend_non_production.tf file it produces
#   backend "s3" {
#     region         = "eu-west-2"
#     bucket         = "core-non-production-terraform-states"
#     key            = "core-meta.tfstate"
#     dynamodb_table = "core-non-production-terraform-states-lock"
#     encrypt        = true
#     role_arn       = "arn:aws:iam::META-ACCOUNT-ID:role/ROLE-NAME"
#   }
}

provider "aws" {
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::META-ACCOUNT-ID:role/ROLE-NAME"
  }
}

### CLOUDPOSSE ###
# We create two backends. One for the meta, development and staging accounts, and one just for production
# You cannot create a new backend by simply defining this and then immediately proceeding to "terraform apply".
# The S3 backend must be bootstrapped according to the simple yet essential procedure in:
# https://github.com/cloudposse/terraform-aws-tfstate-backend#usage
# Fails 12 checkovs - All of them LOW
# Non-production
module "terraform_state_backend_non_production" {
  source = "cloudposse/tfstate-backend/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version    = "1.1.1"
  namespace  = "core"
  stage      = "non-production"
  name       = "terraform"
  attributes = ["states"]

  block_public_acls                  = true
  block_public_policy                = true
  bucket_enabled                     = true
  bucket_ownership_enforced_enabled  = true
  dynamodb_enabled                   = true
  dynamodb_table_name                = "core-non-production-terraform-states-lock"
  enable_point_in_time_recovery      = true
  enable_public_access_block         = true
  enabled                            = true
  environment                        = "meta"
  force_destroy                      = true
  ignore_public_acls                 = true
  prevent_unencrypted_uploads        = true
  restrict_public_buckets            = true
  s3_bucket_name                     = "core-non-production-terraform-states"
  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend_non_production.tf"
}

# Fails 12 checkovs - All of them LOW
# Production
module "terraform_state_backend_production" {
  source = "cloudposse/tfstate-backend/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version    = "1.1.1"
  namespace  = "core"
  stage      = "production"
  name       = "terraform"
  attributes = ["state"]

block_public_acls                  = true
block_public_policy                = true
bucket_enabled                     = true
bucket_ownership_enforced_enabled  = true
dynamodb_enabled                   = true
dynamodb_table_name                = "core-production-terraform-state-lock"
enable_point_in_time_recovery      = true
enable_public_access_block         = true
enabled                            = true
environment                        = "meta"
force_destroy                      = true
ignore_public_acls                 = true
prevent_unencrypted_uploads        = true
restrict_public_buckets            = true
s3_bucket_name                     = "core-production-terraform-state"
terraform_backend_config_file_path = "."
terraform_backend_config_file_name = "backend_production.tf"
}


### NOZAQ ###
# Fails 13 checkovs - All of them LOW
provider "aws" {
  alias = "replica"
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::META-ACCOUNT-ID:role/ROLE-NAME"
  }
}

module "terraform_state_backend" {
  source = "nozaq/remote-state-s3-backend/aws"

  providers = {
    aws         = aws
    aws.replica = aws.replica
  }

  dynamodb_enable_server_side_encryption = true
  dynamodb_table_name = "core-non-production-terraform-states-lock"
  enable_replication = true
  iam_role_arn = "arn:aws:iam::815624722760:role/developer"
  kms_key_alias = "state-key"
  kms_key_deletion_window_in_days = 30
  kms_key_enable_key_rotation = true
  noncurrent_version_expiration = {
    days = 30
  }
  replica_bucket_prefix = "replica"
  s3_bucket_force_destroy = false
  s3_bucket_name = "core-non-production-terraform-states"
  s3_logging_target_bucket = "logging-bucket"
}

### SQUAREOPS ###
# Fails 35 checkovs - the below is all we can configure on the backend module
module "terraform_state_backend" {
  source = "squareops/tfstate/aws"
  logging = true
  environment = "meta"
  bucket_name = "core-non-production-terraform-states"
  force_destroy = false
  versioning_enabled = true
}
