resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-ecs-cluster"
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.prefix}-ecs-task"
  cpu                      = var.ecs_task_cpu
  execution_role_arn       = aws_iam_role.task_execution.arn
  memory                   = var.ecs_task_memory #MiB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name              = "${var.prefix}-ecs-container"
      cpu               = var.ecs_task_cpu
      environment       = var.ecs_environment_variables
      essential         = true
      image             = var.ecr_repository_url
      memoryReservation = var.ecs_task_memory * 0.75

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
          containerPort = 8080
          hostPort      = 8080
        }
      ]

      secrets = [for key, value in var.ecs_parameters : {
        name      = key
        valueFrom = value
      }]

      user = "nonroot"
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_task_definition" "db_migrate" {
  family                   = "${var.prefix}-ecs-db-migrate-task"
  cpu                      = var.ecs_task_cpu
  execution_role_arn       = aws_iam_role.task_execution.arn
  memory                   = var.ecs_task_memory #MiB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name              = "${var.prefix}-ecs-db-migrate-container"
      command           = ["bundle", "exec", "rake", "db:migrate"]
      cpu               = var.ecs_task_cpu
      environment       = var.ecs_environment_variables
      essential         = true
      image             = var.ecr_repository_url
      memoryReservation = var.ecs_task_memory * 0.75

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
          containerPort = 8080
          hostPort      = 8080
        }
      ]

      secrets = [for key, value in var.ecs_parameters : {
        name      = key
        valueFrom = value
      }]

      user = "nonroot"
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_task_definition" "db_seed" {
  family                   = "${var.prefix}-ecs-db-seed-task"
  cpu                      = var.ecs_task_cpu
  execution_role_arn       = aws_iam_role.task_execution.arn
  memory                   = var.ecs_task_memory #MiB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name              = "${var.prefix}-ecs-db-setup-container"
      command           = ["bundle", "exec", "rake", "db:seed"]
      cpu               = var.ecs_task_cpu
      environment       = var.ecs_environment_variables
      essential         = true
      image             = var.ecr_repository_url
      memoryReservation = var.ecs_task_memory * 0.75

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
          containerPort = 8080
          hostPort      = 8080
        }
      ]

      secrets = [for key, value in var.ecs_parameters : {
        name      = key
        valueFrom = value
      }]

      user = "nonroot"
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_task_definition" "db_setup" {
  family                   = "${var.prefix}-ecs-db-setup-task"
  cpu                      = var.ecs_task_cpu
  execution_role_arn       = aws_iam_role.task_execution.arn
  memory                   = var.ecs_task_memory #MiB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name              = "${var.prefix}-ecs-db-setup-container"
      command           = ["bundle", "exec", "rake", "db:setup"]
      cpu               = var.ecs_task_cpu
      environment       = var.ecs_environment_variables
      essential         = true
      image             = var.ecr_repository_url
      memoryReservation = var.ecs_task_memory * 0.75

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
          containerPort = 8080
          hostPort      = 8080
        }
      ]

      secrets = [for key, value in var.ecs_parameters : {
        name      = key
        valueFrom = value
      }]

      user = "nonroot"
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

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }
}
