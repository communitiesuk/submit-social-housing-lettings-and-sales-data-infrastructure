#tfsec:ignore:aws-ecs-enable-container-insight:TODO CLDC-2542 enable container insights if necessary for logging/monitoring
resource "aws_ecs_cluster" "main" {
  #checkov:skip=CKV_AWS_65:TODO CLDC-2542 enable container insights if necessary for logging/monitoring
  name = "${var.prefix}-ecs-cluster"
}

locals {
  export_bucket = "export-bucket"
  s3_config = [
    {
      instance_name : local.export_bucket,
      credentials : var.export_bucket_details
    }
  ]
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
      name = "${var.prefix}-ecs-container"
      cpu  = var.ecs_task_cpu
      environment = [
        { Name = "API_USER", Value = "dluhc-user" },
        { Name = "APP_HOST", Value = var.app_host },
        { Name = "CSV_DOWNLOAD_PAAS_INSTANCE", Value = "" },
        { Name = "EXPORT_PAAS_INSTANCE", Value = local.export_bucket },
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
          awslogs-group         = aws_cloudwatch_log_group.main.id
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

resource "aws_ecs_task_definition" "db_migrate" {
  #checkov:skip=CKV_AWS_336:using readonlyRootFilesystem to true breaks the app, as it needs to write to app/tmp/pids for example
  family                   = "${var.prefix}-ecs-db-migrate-task"
  cpu                      = var.ecs_task_cpu
  execution_role_arn       = aws_iam_role.task_execution.arn
  memory                   = var.ecs_task_memory #MiB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name    = "${var.prefix}-ecs-db-migrate-container"
      command = ["bundle", "exec", "rake", "db:migrate"]
      cpu     = var.ecs_task_cpu
      environment = [
        { Name = "API_USER", Value = "dluhc-user" },
        { Name = "APP_HOST", Value = var.app_host },
        { Name = "CSV_DOWNLOAD_PAAS_INSTANCE", Value = "" },
        { Name = "EXPORT_PAAS_INSTANCE", Value = "" },
        { Name = "IMPORT_PAAS_INSTANCE", Value = "" },
        { Name = "RAILS_ENV", Value = var.rails_env },
        { Name = "RAILS_LOG_TO_STDOUT", Value = "true" },
        { Name = "RAILS_SERVE_STATIC_FILES", Value = "true" },
        { Name = "REDIS_INSTANCE_NAME", Value = "" },
        { Name = "REDIS_CONFIG", Value = "[{\"instance_name\":\"\",\"credentials\":{\"uri\":\"${var.redis_connection_string}\"}}]" },
        { Name = "S3_CONFIG", Value = "" }
      ]
      essential         = true
      image             = var.ecr_repository_url
      memoryReservation = var.ecs_task_memory * 0.75
      user              = "nonroot"

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.main.id
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

resource "aws_ecs_task_definition" "db_seed" {
  #checkov:skip=CKV_AWS_336:using readonlyRootFilesystem to true breaks the app, as it needs to write to app/tmp/pids for example
  family                   = "${var.prefix}-ecs-db-seed-task"
  cpu                      = var.ecs_task_cpu
  execution_role_arn       = aws_iam_role.task_execution.arn
  memory                   = var.ecs_task_memory #MiB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name    = "${var.prefix}-ecs-db-setup-container"
      command = ["bundle", "exec", "rake", "db:seed"]
      cpu     = var.ecs_task_cpu
      environment = [
        { Name = "API_USER", Value = "dluhc-user" },
        { Name = "APP_HOST", Value = var.app_host },
        { Name = "CSV_DOWNLOAD_PAAS_INSTANCE", Value = "" },
        { Name = "EXPORT_PAAS_INSTANCE", Value = "" },
        { Name = "IMPORT_PAAS_INSTANCE", Value = "" },
        { Name = "RAILS_ENV", Value = var.rails_env },
        { Name = "RAILS_LOG_TO_STDOUT", Value = "true" },
        { Name = "RAILS_SERVE_STATIC_FILES", Value = "true" },
        { Name = "REDIS_INSTANCE_NAME", Value = "" },
        { Name = "REDIS_CONFIG", Value = "[{\"instance_name\":\"\",\"credentials\":{\"uri\":\"${var.redis_connection_string}\"}}]" },
        { Name = "S3_CONFIG", Value = "" }
      ]
      essential         = true
      image             = var.ecr_repository_url
      memoryReservation = var.ecs_task_memory * 0.75
      user              = "nonroot"

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.main.id
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

resource "aws_ecs_task_definition" "db_setup" {
  #checkov:skip=CKV_AWS_336:using readonlyRootFilesystem to true breaks the app, as it needs to write to app/tmp/pids for example
  family                   = "${var.prefix}-ecs-db-setup-task"
  cpu                      = var.ecs_task_cpu
  execution_role_arn       = aws_iam_role.task_execution.arn
  memory                   = var.ecs_task_memory #MiB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name    = "${var.prefix}-ecs-db-setup-container"
      command = ["bundle", "exec", "rake", "db:setup"]
      cpu     = var.ecs_task_cpu
      environment = [
        { Name = "API_USER", Value = "dluhc-user" },
        { Name = "APP_HOST", Value = var.app_host },
        { Name = "CSV_DOWNLOAD_PAAS_INSTANCE", Value = "" },
        { Name = "EXPORT_PAAS_INSTANCE", Value = "" },
        { Name = "IMPORT_PAAS_INSTANCE", Value = "" },
        { Name = "RAILS_ENV", Value = var.rails_env },
        { Name = "RAILS_LOG_TO_STDOUT", Value = "true" },
        { Name = "RAILS_SERVE_STATIC_FILES", Value = "true" },
        { Name = "REDIS_INSTANCE_NAME", Value = "" },
        { Name = "REDIS_CONFIG", Value = "[{\"instance_name\":\"\",\"credentials\":{\"uri\":\"${var.redis_connection_string}\"}}]" },
        { Name = "S3_CONFIG", Value = "" }
      ]
      essential         = true
      image             = var.ecr_repository_url
      memoryReservation = var.ecs_task_memory * 0.75
      user              = "nonroot"

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.main.id
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

resource "aws_ecs_service" "main" {
  name                               = "${var.prefix}-ecs-service"
  cluster                            = aws_ecs_cluster.main.arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100 / var.ecs_task_desired_count # always 1 task from the desired count should be running
  desired_count                      = var.ecs_task_desired_count
  enable_execute_command             = true
  force_new_deployment               = true
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  task_definition                    = aws_ecs_task_definition.main.arn

  load_balancer {
    container_name   = "${var.prefix}-ecs-container"
    container_port   = var.application_port
    target_group_arn = var.load_balancer_target_group_arn
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }
}
