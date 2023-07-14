# The state replication bucket is kept in a separate region (eu-west-1) to the source bucket and where we generally
# create our infrastructure (eu-west-2), so we define a provider here to be especially for this
provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::815624722760:role/developer"
  }
}

module "tf_state_replica_bucket" {
  providers = { aws = aws.ireland }
  #checkov:skip=CKV_TF_1:providing git source with commit hash causes filename too long errors on Checkov, and latest module updates are preferred
  #checkov:skip=CKV_AWS_273:iam user for bucket access isn't required nor created by cloudposse with our configuration, so we don't need to ensure this is controlled through SSO instead
  #checkov:skip=CKV_AWS_300:lifecycle configuration is set below for aborting failed uploads, looks like a false flag
  #checkov:skip=CKV2_AWS_34:use of ssm to store a parameter for the access key of an iam user isn't required nor created by cloudposse with our configuration, so we don't need to ensure encryption of the parameter
  #checkov:skip=CKV2_AWS_62:we don't require event notifications on this bucket as it's only replicating the tfstate files as a fallback
  source    = "cloudposse/s3-bucket/aws"

  acl                          = null
  allow_encrypted_uploads_only = true
  allow_ssl_requests_only      = true
  block_public_acls            = true
  block_public_policy          = true
  bucket_name                  = var.state_replication_bucket_name
  enabled                      = true
  environment                  = "meta"
  force_destroy                = false
  ignore_public_acls           = true
  lifecycle_configuration_rules = [{
    abort_incomplete_multipart_upload_days = 1
    enabled                                = true
    expiration                    = {}
    filter_and                    = {}
    id                            = "remove-incomplete-uploads"
    noncurrent_version_expiration = {}
    noncurrent_version_transition = []
    transition                    = []
  }]
  restrict_public_buckets      = true
  s3_object_ownership          = "BucketOwnerEnforced"
  s3_replication_enabled       = false
  sse_algorithm                = "AES256"
  user_enabled                 = false
  versioning_enabled           = true
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "allow_log_writes" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${module.tf_state_log_bucket.bucket_arn}/*"
    ]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [module.tf_state_backend.s3_bucket_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

module "tf_state_log_bucket" {
  #checkov:skip=CKV_TF_1:providing git source with commit hash causes filename too long errors on Checkov, and latest module updates are preferred
  #checkov:skip=CKV_AWS_273:iam user for bucket access isn't required nor created by cloudposse with our configuration, so we don't need to ensure this is controlled through SSO instead
  #checkov:skip=CKV_AWS_300:lifecycle configuration is set below for aborting failed uploads, looks like a false flag
  #checkov:skip=CKV2_AWS_34:use of ssm to store a parameter for the access key of an iam user isn't required nor created by cloudposse with our configuration, so we don't need to ensure encryption of the parameter
  #checkov:skip=CKV2_AWS_62:we don't require event notifications on this bucket as its storing logs continuously and will become a nuisance
  source = "cloudposse/s3-bucket/aws"

  acl                          = null
  allow_encrypted_uploads_only = false
  allow_ssl_requests_only      = false
  block_public_acls            = true
  block_public_policy          = true
  bucket_name                  = var.state_log_bucket_name
  enabled                      = true
  environment                  = "meta"
  force_destroy                = false
  ignore_public_acls           = true
  lifecycle_configuration_rules = [{
    abort_incomplete_multipart_upload_days = 1
    enabled                                = true
    expiration = {
      days                         = 90
      expired_object_delete_marker = false
    }
    filter_and                    = {}
    id                            = "expire-old-logs"
    noncurrent_version_expiration = {}
    noncurrent_version_transition = []
    transition                    = []
  }]
  restrict_public_buckets = true
  s3_object_ownership     = "BucketOwnerEnforced"
  s3_replication_enabled  = false
  source_policy_documents = [data.aws_iam_policy_document.allow_log_writes.json]
  sse_algorithm           = "AES256"
  user_enabled            = false
  versioning_enabled      = false
}

# You cannot create a new backend by simply defining this and then immediately proceeding to "terraform apply".
# The S3 backend must be bootstrapped according to the simple yet essential procedure in:
# https://github.com/cloudposse/terraform-aws-tfstate-backend#usage
module "tf_state_backend" {
  #checkov:skip=CKV_TF_1:providing git source with commit hash causes filename too long errors on Checkov, and latest module updates are preferred
  #checkov:skip=CKV_AWS_119:dynamodb table is used for state locking and not sensitive, so doesn't need encrypting with a customer managed key in KMS
  #checkov:skip=CKV_AWS_145:can't configure S3 bucket encryption with KMS through cloudposse, encryption is enabled using AES:256 instead
  #checkov:skip=CKV2_AWS_61:can't configure S3 bucket lifecycle through cloudposse, not required as we plan to keep all state files on the bucket
  #checkov:skip=CKV2_AWS_62:we don't require event notifications on the state bucket as it only changes with terraform applications, and have access logging enabled
  source = "cloudposse/tfstate-backend/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version = "1.1.1"

  billing_mode                      = "PAY_PER_REQUEST"
  block_public_acls                 = true
  block_public_policy               = true
  bucket_enabled                    = true
  bucket_ownership_enforced_enabled = true
  dynamodb_enabled                  = true
  dynamodb_table_name               = var.state_lock_dynamodb_name
  enable_point_in_time_recovery     = true
  enable_public_access_block        = true
  enabled                           = true
  environment                       = "meta"
  force_destroy                     = false
  ignore_public_acls                = true
  logging = [{
    target_bucket = var.state_log_bucket_name,
    target_prefix = ""
  }]
  prevent_unencrypted_uploads = true
  restrict_public_buckets     = true
  s3_bucket_name              = var.state_bucket_name
  s3_replica_bucket_arn       = module.tf_state_replica_bucket.bucket_arn
  s3_replication_enabled      = true
  # This is the minimum required terraform version
  terraform_version = "1.5.1"
}