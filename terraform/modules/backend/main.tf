terraform {
  required_version = "~>1.5.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

# The state replica bucket is kept in a separate region (eu-west-1) to the source bucket and where we generally
# create our infrastructure (eu-west-2), so we define a provider here especially for this
provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::815624722760:role/developer"
  }
}

locals {
  prefix = "${var.prefix}-tf-state"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "allow_state_bucket_log_writes" {
  statement {
    sid = "S3StateAccessLogging"

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

data "aws_iam_policy_document" "allow_state_replica_bucket_log_writes" {
  statement {
    sid = "S3StateReplicaAccessLogging"

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${module.tf_state_replica_log_bucket.bucket_arn}/*"
    ]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [module.tf_state_replica_bucket.bucket_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

#tfsec:ignore:aws-s3-block-public-acls:block_public_acls is set to true, this is a false flag
#tfsec:ignore:aws-s3-block-public-policy:block_public_policy is set to true, this is a false flag
#tfsec:ignore:aws-s3-enable-bucket-encryption:using AES256 encryption with key managed by Amazon S3 instead of KMS
#tfsec:ignore:aws-s3-ignore-public-acls:ignore_public_acls is set to true, this is a false flag
#tfsec:ignore:aws-s3-no-public-buckets:restrict_public_buckets is set to true, this is a false flag
#tfsec:ignore:aws-s3-encryption-customer-key:using key managed by S3 because bucket will only contain access logs for another bucket
#tfsec:ignore:aws-s3-enable-versioning:versioning not required because log files are unique and only created once
#tfsec:ignore:aws-s3-enable-bucket-logging:access logs are not required for a log bucket
#tfsec:ignore:aws-s3-specify-public-access-block:aws_s3_bucket_public_access_block is being used, this is a false flag
module "tf_state_log_bucket" {
  #checkov:skip=CKV_TF_1:providing git source with commit hash causes filename too long errors on Checkov, and we provide the version
  #checkov:skip=CKV_AWS_273:iam user for bucket access isn't required nor created by cloudposse with our configuration, so we don't need to ensure this is controlled through SSO instead
  #checkov:skip=CKV_AWS_300:lifecycle configuration is set below for aborting failed uploads, looks like a false flag
  #checkov:skip=CKV2_AWS_34:use of ssm to store a parameter for the access key of an iam user isn't required nor created by cloudposse with our configuration, so we don't need to ensure encryption of the parameter
  #checkov:skip=CKV2_AWS_62:we don't require event notifications on this bucket as its storing logs continuously and will become a nuisance
  source = "cloudposse/s3-bucket/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version = "3.1.2"

  acl                          = null
  allow_encrypted_uploads_only = false
  allow_ssl_requests_only      = false
  block_public_acls            = true
  block_public_policy          = true
  bucket_name                  = "${local.prefix}-logs"
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
  source_policy_documents = [data.aws_iam_policy_document.allow_state_bucket_log_writes.json]
  sse_algorithm           = "AES256"
  user_enabled            = false
  versioning_enabled      = false
}

#tfsec:ignore:aws-s3-block-public-acls:block_public_acls is set to true, this is a false flag
#tfsec:ignore:aws-s3-block-public-policy:block_public_policy is set to true, this is a false flag
#tfsec:ignore:aws-s3-enable-bucket-encryption:using AES256 encryption with key managed by Amazon S3 instead of KMS
#tfsec:ignore:aws-s3-ignore-public-acls:ignore_public_acls is set to true, this is a false flag
#tfsec:ignore:aws-s3-no-public-buckets:restrict_public_buckets is set to true, this is a false flag
#tfsec:ignore:aws-s3-encryption-customer-key:using key managed by S3 because bucket will only contain access logs for another bucket
#tfsec:ignore:aws-s3-enable-versioning:versioning not required because log files are unique and only created once
#tfsec:ignore:aws-s3-enable-bucket-logging:access logs are not required for a log bucket
#tfsec:ignore:aws-s3-specify-public-access-block:aws_s3_bucket_public_access_block is being used, this is a false flag
module "tf_state_replica_log_bucket" {
  #checkov:skip=CKV_TF_1:providing git source with commit hash causes filename too long errors on Checkov, and we provide the version
  #checkov:skip=CKV_AWS_273:iam user for bucket access isn't required nor created by cloudposse with our configuration, so we don't need to ensure this is controlled through SSO instead
  #checkov:skip=CKV_AWS_300:lifecycle configuration is set below for aborting failed uploads, looks like a false flag
  #checkov:skip=CKV2_AWS_34:use of ssm to store a parameter for the access key of an iam user isn't required nor created by cloudposse with our configuration, so we don't need to ensure encryption of the parameter
  #checkov:skip=CKV2_AWS_62:we don't require event notifications on this bucket as its storing logs continuously and will become a nuisance
  providers = { aws = aws.ireland }
  source    = "cloudposse/s3-bucket/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version = "3.1.2"

  acl                          = null
  allow_encrypted_uploads_only = false
  allow_ssl_requests_only      = false
  block_public_acls            = true
  block_public_policy          = true
  bucket_name                  = "${local.prefix}-replica-logs"
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
  source_policy_documents = [data.aws_iam_policy_document.allow_state_replica_bucket_log_writes.json]
  sse_algorithm           = "AES256"
  user_enabled            = false
  versioning_enabled      = false
}

#tfsec:ignore:aws-s3-block-public-acls:block_public_acls is set to true, this is a false flag
#tfsec:ignore:aws-s3-block-public-policy:block_public_policy is set to true, this is a false flag
#tfsec:ignore:aws-s3-enable-bucket-encryption:using AES256 encryption with key managed by Amazon S3 instead of KMS
#tfsec:ignore:aws-s3-ignore-public-acls:ignore_public_acls is set to true, this is a false flag
#tfsec:ignore:aws-s3-no-public-buckets:restrict_public_buckets is set to true, this is a false flag
#tfsec:ignore:aws-s3-encryption-customer-key:using key managed by S3 because cloudposse backend module can't be configured with KMS
#tfsec:ignore:aws-s3-enable-versioning:versioning not required for replica of a bucket with versioning enabled
#tfsec:ignore:aws-s3-enable-bucket-logging:access logs are being taken, this is a false flag
#tfsec:ignore:aws-s3-specify-public-access-block:aws_s3_bucket_public_access_block is being used, this is a false flag
module "tf_state_replica_bucket" {
  #checkov:skip=CKV_TF_1:providing git source with commit hash causes filename too long errors on Checkov, and we provide the version
  #checkov:skip=CKV_AWS_273:iam user for bucket access isn't required nor created by cloudposse with our configuration, so we don't need to ensure this is controlled through SSO instead
  #checkov:skip=CKV_AWS_300:lifecycle configuration is set below for aborting failed uploads, looks like a false flag
  #checkov:skip=CKV2_AWS_34:use of ssm to store a parameter for the access key of an iam user isn't required nor created by cloudposse with our configuration, so we don't need to ensure encryption of the parameter
  #checkov:skip=CKV2_AWS_62:we don't require event notifications on this bucket as it's only replicating the tfstate files as a fallback
  providers = { aws = aws.ireland }
  source    = "cloudposse/s3-bucket/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version = "3.1.2"

  acl                          = null
  allow_encrypted_uploads_only = true
  allow_ssl_requests_only      = true
  block_public_acls            = true
  block_public_policy          = true
  bucket_name                  = "${local.prefix}-replica"
  enabled                      = true
  environment                  = "meta"
  force_destroy                = false
  ignore_public_acls           = true
  lifecycle_configuration_rules = [{
    abort_incomplete_multipart_upload_days = 1
    enabled                                = true
    expiration                             = {}
    filter_and                             = {}
    id                                     = "remove-incomplete-uploads"
    noncurrent_version_expiration          = {}
    noncurrent_version_transition          = []
    transition                             = []
  }]
  logging = {
    bucket_name = "${local.prefix}-replica-logs",
    prefix      = ""
  }
  restrict_public_buckets = true
  s3_object_ownership     = "BucketOwnerEnforced"
  s3_replication_enabled  = false
  sse_algorithm           = "AES256"
  user_enabled            = false
  versioning_enabled      = true
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
  dynamodb_table_name               = "${local.prefix}-lock"
  enable_point_in_time_recovery     = true
  enable_public_access_block        = true
  enabled                           = true
  environment                       = "meta"
  force_destroy                     = false
  ignore_public_acls                = true
  logging = [{
    target_bucket = "${local.prefix}-logs",
    target_prefix = ""
  }]
  prevent_unencrypted_uploads = true
  restrict_public_buckets     = true
  s3_bucket_name              = local.prefix
  s3_replica_bucket_arn       = module.tf_state_replica_bucket.bucket_arn
  s3_replication_enabled      = true
  # This is the minimum required terraform version
  terraform_version = "1.5.1"
}
