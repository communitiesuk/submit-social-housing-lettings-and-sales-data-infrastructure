#tfsec:ignore:aws-ecs-enable-container-insight: Don't need container insights here
resource "aws_ecs_cluster" "this" {
  #checkov:skip=CKV_AWS_65: Don't need container insights here
  name = "core-performance-testing"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "core-performance-testing"
  cpu                      = 512
  execution_role_arn       = aws_iam_role.task_execution.arn
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "performance-testing"
      essential = true
      image     = aws_ecr_repository.this.repository_url

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group   = aws_cloudwatch_log_group.this.id
          awslogs-region  = "eu-west-1"
          mode            = "non-blocking"
          max-buffer-size = "4m"
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "core-performance-testing"
  retention_in_days = 90
} 