terraform {
  required_version = "~>1.5.1"

  required_providers {
    aws = {
      version = "~>5.0"
      source  = "hashicorp/aws"
    }
  }

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

  assume_role {
    role_arn = local.provider_role_arn
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"

  assume_role {
    role_arn = local.provider_role_arn
  }
}

locals {
  prefix            = "core-dev"
  application_port  = 8080
  database_port     = 5432
  provider_role_arn = "arn:aws:iam::837698168072:role/developer"
  redis_port        = 6379
}

module "application1" {
  source = "../modules/application"

  prefix                               = "dev-1"
  app_host                             = ""
  app_task_cpu                         = 512
  app_task_desired_count               = 2
  app_task_memory                      = 1024
  application_port                     = local.application_port
  bulk_upload_bucket_access_policy_arn = module.bulk_upload.read_write_policy_arn
  bulk_upload_bucket_details           = module.bulk_upload.details
  database_connection_string_arn       = module.database.one_connection_string_arn
  database_data_access_policy_arn      = module.database.rds_data_access_policy_arn
  database_port                        = local.database_port
  db_security_group_id                 = module.database.rds_security_group_id
  ecr_repository_url                   = "815624722760.dkr.ecr.eu-west-2.amazonaws.com/core"
  export_bucket_access_policy_arn      = module.cds_export.read_write_policy_arn
  export_bucket_details                = module.cds_export.details
  github_actions_role_arn              = "arn:aws:iam::815624722760:role/core-application-repo"
  load_balancer_security_group_id      = aws_security_group.load_balancer.id
  load_balancer_target_group_arn       = aws_lb_target_group.one.arn
  private_subnet_ids                   = module.networking.private_subnet_ids
  redis_connection_string              = module.redis.redis_connection_string
  rails_env                            = "review"
  redis_port                           = local.redis_port
  redis_security_group_id              = module.redis.redis_security_group_id
  sidekiq_task_cpu                     = 512
  sidekiq_task_desired_count           = 1
  sidekiq_task_memory                  = 1024
  vpc_id                               = module.networking.vpc_id
  api_key = aws_secretsmanager_secret.api_key.arn
  notify = aws_secretsmanager_secret.govuk_notify_api_key.arn
  os = aws_secretsmanager_secret.os_data_key.arn
  rails = aws_secretsmanager_secret.rails_master_key.arn
  sentry = aws_secretsmanager_secret.sentry_dsn.arn
  root = "/one"
}

module "application2" {
  source = "../modules/application"

  prefix                               = "dev-2"
  app_host                             = ""
  app_task_cpu                         = 512
  app_task_desired_count               = 2
  app_task_memory                      = 1024
  application_port                     = local.application_port
  bulk_upload_bucket_access_policy_arn = module.bulk_upload.read_write_policy_arn
  bulk_upload_bucket_details           = module.bulk_upload.details
  database_connection_string_arn       = module.database.two_connection_string_arn
  database_data_access_policy_arn      = module.database.rds_data_access_policy_arn
  database_port                        = local.database_port
  db_security_group_id                 = module.database.rds_security_group_id
  ecr_repository_url                   = "815624722760.dkr.ecr.eu-west-2.amazonaws.com/core"
  export_bucket_access_policy_arn      = module.cds_export.read_write_policy_arn
  export_bucket_details                = module.cds_export.details
  github_actions_role_arn              = "arn:aws:iam::815624722760:role/core-application-repo"
  load_balancer_security_group_id      = aws_security_group.load_balancer.id
  load_balancer_target_group_arn       = aws_lb_target_group.two.arn
  private_subnet_ids                   = module.networking.private_subnet_ids
  redis_connection_string              = module.redis.redis_connection_string
  rails_env                            = "review"
  redis_port                           = local.redis_port
  redis_security_group_id              = module.redis.redis_security_group_id
  sidekiq_task_cpu                     = 512
  sidekiq_task_desired_count           = 1
  sidekiq_task_memory                  = 1024
  vpc_id                               = module.networking.vpc_id
    api_key = aws_secretsmanager_secret.api_key.arn
  notify = aws_secretsmanager_secret.govuk_notify_api_key.arn
  os = aws_secretsmanager_secret.os_data_key.arn
  rails = aws_secretsmanager_secret.rails_master_key.arn
  sentry = aws_secretsmanager_secret.sentry_dsn.arn
  root = "/two"
}

#tfsec:ignore:aws-ssm-secret-use-customer-key:default encryption key is sufficient
resource "aws_secretsmanager_secret" "api_key" {
  #checkov:skip=CKV_AWS_149:default encryption key is sufficient
  #checkov:skip=CKV2_AWS_57:secret doesn't require automatic rotation
  name = "dev-api-key"
}

#tfsec:ignore:aws-ssm-secret-use-customer-key:default encryption key is sufficient
resource "aws_secretsmanager_secret" "govuk_notify_api_key" {
  #checkov:skip=CKV_AWS_149:default encryption key is sufficient
  #checkov:skip=CKV2_AWS_57:secret is fixed, can't be automatically rotated
  name = "dev-notify"
}

#tfsec:ignore:aws-ssm-secret-use-customer-key:default encryption key is sufficient
resource "aws_secretsmanager_secret" "os_data_key" {
  #checkov:skip=CKV_AWS_149:default encryption key is sufficient
  #checkov:skip=CKV2_AWS_57:secret is fixed, can't be automatically rotated
  name = "dev-os"
}

#tfsec:ignore:aws-ssm-secret-use-customer-key:default encryption key is sufficient
resource "aws_secretsmanager_secret" "rails_master_key" {
  #checkov:skip=CKV_AWS_149:default encryption key is sufficient
  #checkov:skip=CKV2_AWS_57:secret doesn't require automatic rotation
  name = "dev-rails"
}

#tfsec:ignore:aws-ssm-secret-use-customer-key:default encryption key is sufficient
resource "aws_secretsmanager_secret" "sentry_dsn" {
  #checkov:skip=CKV_AWS_149:default encryption key is sufficient
  #checkov:skip=CKV2_AWS_57:secret is fixed, can't be automatically rotated
  name = "dev-sentry"
}

resource "aws_lb" "this" {
  name                       = "dev"
  drop_invalid_header_fields = true
  enable_deletion_protection = true
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.load_balancer.id]
  subnets                    = module.networking.public_subnet_ids
}

resource "aws_lb_target_group" "one" {
  name        = "dev-1"
  port        = local.application_port
  protocol    = "HTTP"
  vpc_id      = module.networking.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "204"
    timeout             = "3"
    path                = "/one/health"
    unhealthy_threshold = "2"
  }
}

resource "aws_lb_target_group" "two" {
  name        = "dev-2"
  port        = local.application_port
  protocol    = "HTTP"
  vpc_id      = module.networking.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "204"
    timeout             = "3"
    path                = "/two/health"
    unhealthy_threshold = "2"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    order = 50000

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "one" {
  listener_arn = aws_lb_listener.http.arn

  action {
    target_group_arn = aws_lb_target_group.one.id
    type             = "forward"
  }

  condition {
    path_pattern {
      values = ["/one/*"]
    }
  }
}

resource "aws_lb_listener_rule" "two" {
  listener_arn = aws_lb_listener.http.arn

  action {
    target_group_arn = aws_lb_target_group.two.id
    type             = "forward"
  }

  condition {
    path_pattern {
      values = ["/two/*"]
    }
  }
}

resource "aws_security_group" "load_balancer" {
  name        = "dev-load-balancer"
  description = "Load Balancer security group"
  vpc_id      = module.networking.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "load_balancer_http_ingress" {
  #checkov:skip=CKV_AWS_260:ingress from all IPs to port 80 required as load balancer is public
  description       = "Allow http ingress from all IP addresses"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_vpc_security_group_ingress_rule" "load_balancer_https_ingress" {
  description       = "Allow https ingress from all IP addresses"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_vpc_security_group_egress_rule" "load_balancer_container_egress" {
  description                  = "Allow egress to ecs"
  ip_protocol                  = "tcp"
  from_port                    = local.application_port
  to_port                      = local.application_port
  security_group_id            = aws_security_group.load_balancer.id
  cidr_ipv4                    = "0.0.0.0/0"
}

module "bulk_upload" {
  source = "../modules/bulk_upload"

  prefix = local.prefix
}

module "cds_export" {
  source = "../modules/cds_export"

  prefix = local.prefix
}

module "database" {
  source = "../modules/rds"

  prefix                  = local.prefix
  allocated_storage       = 5
  backup_retention_period = 7
  db_subnet_group_name    = module.networking.db_private_subnet_group_name
  database_port           = local.database_port
  ecs_security_group_id_one   = module.application1.ecs_security_group_id
  ecs_security_group_id_two   = module.application2.ecs_security_group_id
  instance_class          = "db.t3.micro"
  vpc_id                  = module.networking.vpc_id
}

module "networking" {
  source = "../modules/networking"

  prefix                                  = local.prefix
  vpc_cidr_block                          = "10.0.0.0/16"
  vpc_flow_cloudwatch_log_expiration_days = 90
}

module "redis" {
  source = "../modules/elasticache"

  prefix                  = local.prefix
  ecs_security_group_id_one   = module.application1.ecs_security_group_id
  ecs_security_group_id_two   = module.application2.ecs_security_group_id
  node_type               = "cache.t4g.micro"
  redis_port              = local.redis_port
  redis_subnet_group_name = module.networking.redis_private_subnet_group_name
  vpc_id                  = module.networking.vpc_id
}
