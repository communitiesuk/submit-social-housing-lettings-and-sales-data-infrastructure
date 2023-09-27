resource "aws_cloudwatch_event_rule" "app_task_exited" {
  name = "${var.prefix}-app-task-exited"

  event_pattern = jsonencode(
    {
      "source" : [
        "aws.ecs"
      ],
      "detail-type" : [
        "ECS Task State Change"
      ],
      "detail" : {
        "group" : [
          "service:${aws_ecs_service.app.name}"
        ],
        "stoppedReason" : [
          "Essential container in task exited"
        ]
      }
    }
  )
}

resource "aws_cloudwatch_event_rule" "app_service_action_problem" {
  name = "${var.prefix}-app-service-action-problem"

  # This event pattern was used based on the answer here: https://serverfault.com/questions/1012603/create-a-cloudwatch-alarm-when-an-ecs-service-unable-to-consistently-start-tasks.
  event_pattern = jsonencode(
    {
      "source" : [
        "aws.ecs"
      ],
      "detail-type" : [
        "ECS Service Action"
      ],
      "resources" : [
        aws_ecs_service.app.arn
      ],
      "detail" : {
        "eventType" : ["WARN", "ERROR"]
      }
    }
  )
}
