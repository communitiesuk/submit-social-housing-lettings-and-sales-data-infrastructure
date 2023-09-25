resource "aws_cloudwatch_event_rule" "app_task_exited" {
  name        = "${var.prefix}-app-task-exited"

  event_pattern = jsonencode(
    {
        "source": [
            "aws.ecs"
        ],
        "detail-type": [
            "ECS Task State Change"
        ],
        "detail": {
            "group": [
                "service:${aws_ecs_service.app.name}"
            ],
            "stoppedReason": [
                "Essential container in task exited"
            ]
        }
    }
  )

}
