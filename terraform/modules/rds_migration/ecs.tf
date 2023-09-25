#tfsec:ignore:aws-ecs-enable-container-insight:TODO CLDC-2542 enable container insights if necessary for logging/monitoring
resource "aws_ecs_cluster" "this" {
  #checkov:skip=CKV_AWS_65:TODO CLDC-2542 enable container insights if necessary for logging/monitoring
  name = "${var.prefix}-db-migration"
}

resource "aws_ecs_task_definition" "ad_hoc_db_migration" {
  #checkov:skip=CKV_AWS_336:using readonlyRootFilesystem to true breaks the app, as it needs to write to app/tmp/pids for example
  family                   = "${var.prefix}-ad-hoc-db-migration"
  cpu                      = var.db_migration_task_cpu
  execution_role_arn       = var.ecs_task_execution_role_arn
  memory                   = var.db_migration_task_memory #MiB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "db-migration"
      essential = true
      image     = var.ecr_repository_url

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.id
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = var.prefix
        }
      }

      secrets = [
        { Name = "DATABASE_URL", valueFrom = var.database_connection_string_arn },
        { Name = "CF_PASSWORD", valueFrom = aws_secretsmanager_secret.cloudfoundry_password.arn },
        { Name = "CF_SERVICE", valueFrom = aws_secretsmanager_secret.cloudfoundry_service.arn },
        { Name = "CF_SPACE", valueFrom = aws_secretsmanager_secret.cloudfoundry_space.arn },
        { Name = "CF_USERNAME", valueFrom = aws_secretsmanager_secret.cloudfoundry_username.arn }
      ]
    }
  ])

  ephemeral_storage {
    size_in_gib = var.ecs_task_ephemeral_storage
  }

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  lifecycle {
    # The image will be updated by deployments - irritatingly we can't ignore changes just to the image
    # If changing other aspects of the container definition we'll need to temporarily not ignore changes
    # to force the update, ensuring the referenced image is the correct current one
    ignore_changes = [container_definitions]
  }
}

# This ECS task just runs continuously in the background doing nothing. This is so we can exec into it later and check the DB
resource "aws_ecs_task_definition" "exec_placeholder" {
  #checkov:skip=CKV_AWS_336:using readonlyRootFilesystem to true breaks the app, as it needs to write to app/tmp/pids for example
  family                   = "${var.prefix}-exec-placeholder"
  cpu                      = var.db_migration_task_cpu
  execution_role_arn       = var.ecs_task_execution_role_arn
  memory                   = var.db_migration_task_memory #MiB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name = "db-migration"
      #A command that will keep the placeholding task running. Keeps looking for changes in the file (which should always exist) to display
      command   = ["tail", "-f", "/dev/null"]
      essential = true
      image     = var.ecr_repository_url

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.id
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = var.prefix
        }
      }

      secrets = [
        { Name = "DATABASE_URL", valueFrom = var.database_connection_string_arn }
      ]
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  lifecycle {
    # The image will be updated by deployments - irritatingly we can't ignore changes just to the image
    # If changing other aspects of the container definition we'll need to temporarily not ignore changes
    # to force the update, ensuring the referenced image is the correct current one
    ignore_changes = [container_definitions]
  }
}

resource "aws_ecs_service" "db_migration" {
  name                               = "${var.prefix}-db-migration"
  cluster                            = aws_ecs_cluster.this.arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100 # There should always be at least the desired count running during a deployment
  desired_count                      = 1
  enable_execute_command             = true
  force_new_deployment               = true
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  task_definition                    = aws_ecs_task_definition.exec_placeholder.arn

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  lifecycle {
    # The task definition revision will be updated by the deployment process
    ignore_changes = [task_definition]
  }
}
