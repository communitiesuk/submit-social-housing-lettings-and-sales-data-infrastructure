resource "aws_ecs_cluster" "this" {
  name = "${var.prefix}-s3-migration"
}

locals {
  cpu     = 512
  memory  = 1024
  storage = 20
}

resource "aws_ecs_task_definition" "bucket_migration" {
  #checkov:skip=CKV_AWS_336:setting readonlyRootFilesystem to true breaks the task, as it needs to write to open/root/.cf/temp-config... for example
  for_each = var.buckets

  family                   = "${var.prefix}-${each.key}-s3-migration"
  cpu                      = local.cpu
  execution_role_arn       = aws_iam_role.task_execution.arn
  memory                   = local.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task

  container_definitions = jsonencode([
    {
      name      = "${each.key}-migration"
      essential = true
      image     = var.ecr_repository_url

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.id
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = var.prefix
          mode                  = "non-blocking"
          max-buffer-size       = "4m"
        }
      }

      environment = [
        { Name = "PAAS_BUCKET", value = each.value.source },
        { Name = "NEW_BUCKET", value = each.value.destination }
      ]

      secrets = [
        { Name = "PAAS_ACCESS_KEY_ID", valueFrom = aws_secretsmanager_secret.paas_bucket_access_key_id[each.key].arn },
        { Name = "PAAS_SECRET_ACCESS_KEY", valueFrom = aws_secretsmanager_secret.paas_bucket_secret_access_key[each.key].arn }
      ]
    }
  ])

  ephemeral_storage {
    size_in_gib = 20
  }

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}