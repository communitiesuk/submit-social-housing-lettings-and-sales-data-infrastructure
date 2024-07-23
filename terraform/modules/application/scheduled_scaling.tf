resource "aws_appautoscaling_target" "app" {
  max_capacity       = var.app_task_desired_count
  min_capacity       = var.app_task_desired_count
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_target" "sidekiq" {
  max_capacity       = var.sidekiq_task_desired_count
  min_capacity       = var.sidekiq_task_desired_count
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.sidekiq.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_scheduled_action" "app_workday_on" {
  count = var.out_of_hours_scale_down.enabled ? 1 : 0

  name               = "${var.prefix}-app-workday-on"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  schedule           = "cron(${var.out_of_hours_scale_down.timings.workday_start} ? * MON-FRI *)"
  timezone           = "Europe/London"

  scalable_target_action {
    min_capacity = var.app_task_desired_count
    max_capacity = var.app_task_desired_count
  }
}

resource "aws_appautoscaling_scheduled_action" "app_workday_off" {
  count = var.out_of_hours_scale_down.enabled ? 1 : 0

  name               = "${var.prefix}-app-workday-off"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  schedule           = "cron(${var.out_of_hours_scale_down.timings.workday_end} ? * MON-FRI *)"
  timezone           = "Europe/London"

  scalable_target_action {
    min_capacity = var.out_of_hours_scale_down.scale_to.app
    max_capacity = var.out_of_hours_scale_down.scale_to.app
  }

  # These must be created in series
  depends_on = [aws_appautoscaling_scheduled_action.app_workday_on]
}

resource "aws_appautoscaling_scheduled_action" "sidekiq_workday_on" {
  count = var.out_of_hours_scale_down.enabled ? 1 : 0

  name               = "${var.prefix}-sidekiq-workday-on"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.sidekiq.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  schedule           = "cron(${var.out_of_hours_scale_down.timings.workday_start} ? * MON-FRI *)"
  timezone           = "Europe/London"

  scalable_target_action {
    min_capacity = var.sidekiq_task_desired_count
    max_capacity = var.sidekiq_task_desired_count
  }
}

resource "aws_appautoscaling_scheduled_action" "sidekiq_workday_off" {
  count = var.out_of_hours_scale_down.enabled ? 1 : 0

  name               = "${var.prefix}-sidekiq-workday-off"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.sidekiq.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  schedule           = "cron(${var.out_of_hours_scale_down.timings.workday_end} ? * MON-FRI *)"
  timezone           = "Europe/London"

  scalable_target_action {
    min_capacity = var.out_of_hours_scale_down.scale_to.sidekiq
    max_capacity = var.out_of_hours_scale_down.scale_to.sidekiq
  }

  # These must be created in series
  depends_on = [aws_appautoscaling_scheduled_action.sidekiq_workday_on]
}