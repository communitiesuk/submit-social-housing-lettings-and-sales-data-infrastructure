#tfsec:ignore:aws-ecs-enable-container-insight: Don't need container insights here
resource "aws_ecs_cluster" "this" {
  #checkov:skip=CKV_AWS_65: Don't need container insights here
  name = "core-performance-testing"
}

resource "aws_ecs_task_definition" "this" {
  #chekov:skip=CKV_AWS_336: require write access to file system
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
          awslogs-group         = aws_cloudwatch_log_group.this.id
          awslogs-region        = "eu-west-1"
          awslogs-stream-prefix = "core-perf"
          mode                  = "non-blocking"
          max-buffer-size       = "4m"
        }
      }

      environment = [
        { Name = "OUTPUT_BUCKET", value = aws_s3_bucket.results.id }
      ]
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

#tfsec:ignore:aws-cloudwatch-log-group-customer-key - these aren't sensitive, consider later (CLDC-3006)
resource "aws_cloudwatch_log_group" "this" {
  #chekov:skip=CKV_AWS_158 (encryption with KMS, see above)
  name              = "core-performance-testing"
  retention_in_days = 90
} 