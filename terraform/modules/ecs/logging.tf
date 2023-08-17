# TODO CLDC-2542 remove/modify this temporary logging setup
resource "aws_cloudwatch_log_group" "main" {
  name = "${var.prefix}-ecs-debugging-lg"

  tags = {
    Application = var.prefix
  }
}
