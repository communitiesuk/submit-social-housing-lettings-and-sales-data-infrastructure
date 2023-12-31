#tfsec:ignore:aws-ecs-enable-container-insight:TODO CLDC-2542 enable container insights if necessary for logging/monitoring
resource "aws_ecs_cluster" "this" {
  #checkov:skip=CKV_AWS_65:TODO CLDC-2542 enable container insights if necessary for logging/monitoring
  name = "${var.prefix}-db-migration"
}

resource "aws_ecs_task_definition" "db_migration" {
  #checkov:skip=CKV_AWS_336:setting readonlyRootFilesystem to true breaks the task, as it needs to write to open/root/.cf/temp-config... for example
  family                   = "${var.prefix}-db-migration"
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
          mode                  = "non-blocking"
          max-buffer-size       = "4m" # See this analysis of how to choose a buffer size in non-blocking mode: https://github.com/moby/moby/issues/45999.
        }
      }

      environment = [
        { Name = "CF_SERVICE", Value = var.cloudfoundry_service },
        { Name = "CF_SPACE", Value = var.cloudfoundry_space }
      ]

      secrets = [
        { Name = "DATABASE_URL", valueFrom = var.database_complete_connection_string_arn },
        { Name = "CF_PASSWORD", valueFrom = aws_secretsmanager_secret.cloudfoundry_password.arn },
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
}

# This ECS task just runs continuously in the background doing nothing. This is so we can exec into it later and check the DB
resource "aws_ecs_task_definition" "exec_placeholder" {
  #checkov:skip=CKV_AWS_336:setting readonlyRootFilesystem to true might restrict our ability to use exec to debug things e.g. a cf command might need to write to open/root/.cf/temp-config...
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
      # A command that just keeps the placeholding task running, by continuously looking for changes in a file to display (which doesn't change but should always exist)
      command   = ["tail", "-f", "/dev/null"]
      essential = true
      image     = var.ecr_repository_url

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.id
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = var.prefix
          mode                  = "non-blocking"
          max-buffer-size       = "4m" # See this analysis of how to choose a buffer size in non-blocking mode: https://github.com/moby/moby/issues/45999.
        }
      }

      secrets = [
        { Name = "DATABASE_URL", valueFrom = var.database_complete_connection_string_arn }
      ]
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}
