data "aws_iam_policy_document" "parameter_access" {
  statement {
    sid       = "${upper(var.prefix)}-AllowParameterAccess"
    actions   = ["ssm:GetParameters"]
    resources = [aws_ssm_parameter.complete_database_connection_string.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "parameter_access" {
  name   = "${var.prefix}-parameter-access"
  policy = data.aws_iam_policy_document.parameter_access.json
}

resource "aws_iam_role_policy_attachment" "parameter_access" {
  role       = var.ecs_task_execution_role_name
  policy_arn = aws_iam_policy.parameter_access.arn
}
