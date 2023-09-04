#tfsec:ignore:aws-ecs-enable-container-insight:TODO CLDC-2542 enable container insights if necessary for logging/monitoring
resource "aws_ecs_cluster" "this" {
  #checkov:skip=CKV_AWS_65:TODO CLDC-2542 enable container insights if necessary for logging/monitoring
  name = "${var.prefix}"
}

locals {
  container_name         = "${var.prefix}-app"
  export_bucket_key      = "export-bucket"
  bulk_upload_bucket_key = "bulk-upload-bucket"
  s3_config = [
    {
      instance_name : local.bulk_upload_bucket_key,
      credentials : var.bulk_upload_bucket_details
    },
    {
      instance_name : local.export_bucket_key,
      credentials : var.export_bucket_details
    },
  ]
}

resource "aws_ecs_task_definition" "template" {
  #checkov:skip=CKV_AWS_336:using readonlyRootFilesystem to true breaks the app, as it needs to write to app/tmp/pids for example
  family                   = "${var.prefix}-app-template"
  cpu                      = var.ecs_task_cpu
  execution_role_arn       = aws_iam_role.task_execution.arn
  memory                   = var.ecs_task_memory #MiB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name = local.container_name
      cpu  = var.ecs_task_cpu
      environment = [
        { Name = "API_USER", Value = "dluhc-user" },
        { Name = "APP_HOST", Value = var.app_host },
        { Name = "CSV_DOWNLOAD_PAAS_INSTANCE", Value = local.bulk_upload_bucket_key },
        { Name = "EXPORT_PAAS_INSTANCE", Value = local.export_bucket_key },
        { Name = "IMPORT_PAAS_INSTANCE", Value = "" },
        { Name = "RAILS_ENV", Value = var.rails_env },
        { Name = "RAILS_LOG_TO_STDOUT", Value = "true" },
        { Name = "RAILS_SERVE_STATIC_FILES", Value = "true" },
        { Name = "REDIS_INSTANCE_NAME", Value = "" },
        { Name = "REDIS_CONFIG", Value = "[{\"instance_name\":\"\",\"credentials\":{\"uri\":\"${var.redis_connection_string}\"}}]" },
        { Name = "S3_CONFIG", Value = jsonencode(local.s3_config) }
      ]
      essential         = true
      image             = var.ecr_repository_url
      memoryReservation = var.ecs_task_memory * 0.75
      user              = "nonroot"

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.id
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = var.prefix
        }
      }

      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.application_port
          hostPort      = var.application_port
        }
      ]

      secrets = [
        { Name = "API_KEY", valueFrom = aws_secretsmanager_secret.api_key.arn },
        { Name = "DATABASE_URL", valueFrom = var.database_connection_string_arn },
        { Name = "GOVUK_NOTIFY_API_KEY", valueFrom = aws_secretsmanager_secret.govuk_notify_api_key.arn },
        { Name = "OS_DATA_KEY", valueFrom = aws_secretsmanager_secret.os_data_key.arn },
        { Name = "RAILS_MASTER_KEY", valueFrom = aws_secretsmanager_secret.rails_master_key.arn },
        { Name = "SENTRY_DSN", valueFrom = aws_secretsmanager_secret.sentry_dsn.arn }
      ]
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_task_definition" "main" {
  #checkov:skip=CKV_AWS_336:using readonlyRootFilesystem to true breaks the app, as it needs to write to app/tmp/pids for example
  family                   = "${var.prefix}-ecs-task"
  cpu                      = var.ecs_task_cpu
  execution_role_arn       = aws_iam_role.task_execution.arn
  memory                   = var.ecs_task_memory #MiB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name = local.container_name
      cpu  = var.ecs_task_cpu
      environment = [
        { Name = "API_USER", Value = "dluhc-user" },
        { Name = "APP_HOST", Value = var.app_host },
        { Name = "CSV_DOWNLOAD_PAAS_INSTANCE", Value = local.bulk_upload_bucket_key },
        { Name = "EXPORT_PAAS_INSTANCE", Value = local.export_bucket_key },
        { Name = "IMPORT_PAAS_INSTANCE", Value = "" },
        { Name = "RAILS_ENV", Value = var.rails_env },
        { Name = "RAILS_LOG_TO_STDOUT", Value = "true" },
        { Name = "RAILS_SERVE_STATIC_FILES", Value = "true" },
        { Name = "REDIS_INSTANCE_NAME", Value = "" },
        { Name = "REDIS_CONFIG", Value = "[{\"instance_name\":\"\",\"credentials\":{\"uri\":\"${var.redis_connection_string}\"}}]" },
        { Name = "S3_CONFIG", Value = jsonencode(local.s3_config) }
      ]
      essential         = true
      image             = var.ecr_repository_url
      memoryReservation = var.ecs_task_memory * 0.75
      user              = "nonroot"

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.id
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = var.prefix
        }
      }

      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.application_port
          hostPort      = var.application_port
        }
      ]

      secrets = [
        { Name = "API_KEY", valueFrom = aws_secretsmanager_secret.api_key.arn },
        { Name = "DATABASE_URL", valueFrom = var.database_connection_string_arn },
        { Name = "GOVUK_NOTIFY_API_KEY", valueFrom = aws_secretsmanager_secret.govuk_notify_api_key.arn },
        { Name = "OS_DATA_KEY", valueFrom = aws_secretsmanager_secret.os_data_key.arn },
        { Name = "RAILS_MASTER_KEY", valueFrom = aws_secretsmanager_secret.rails_master_key.arn },
        { Name = "SENTRY_DSN", valueFrom = aws_secretsmanager_secret.sentry_dsn.arn }
      ]
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_task_definition" "ad_hoc_tasks" {
  family = "${var.prefix}-ad-hoc"
  container_definitions = jsonencode([{
    name              = local.container_name
    image             = var.ecr_repository_url
    user              = "nonroot"
    memoryReservation = var.ecs_task_memory * 0.75
  }])

  lifecycle {
    # This definition will be updated on deployments based on the template definition
    ignore_changes = all
  }
}

resource "aws_ecs_service" "this" {
  name                               = "${var.prefix}"
  cluster                            = aws_ecs_cluster.this.arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100 / var.ecs_task_desired_count # always 1 task from the desired count should be running
  desired_count                      = var.ecs_task_desired_count
  enable_execute_command             = true
  force_new_deployment               = true
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  task_definition                    = aws_ecs_task_definition.main.arn

  load_balancer {
    container_name   = local.container_name
    container_port   = var.application_port
    target_group_arn = var.load_balancer_target_group_arn
  }

  network_configuration {
    security_groups  = [aws_security_group.this.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }
}
