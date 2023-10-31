data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution" {
  name               = "core-performance-testing-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

resource "aws_iam_role_policy_attachment" "task_execution_managed_policy" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "allow_kms_decryption" {
  statement {
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.this.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "allow_kms_decryption" {
  name   = "core-performance-testing-allow-kms-decryption"
  policy = data.aws_iam_policy_document.allow_kms_decryption.json
}

resource "aws_iam_role_policy_attachment" "task_execution_allow_kms_decryption" {
  role       = aws_iam_role.task_execution.name
  policy_arn = aws_iam_policy.allow_kms_decryption.arn
}

resource "aws_iam_role" "task" {
  name               = "core-performance-testing-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}


data "aws_iam_policy_document" "results_read_write" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.results.arn]
    effect    = "Allow"
  }

  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.results.arn}/*"]
    effect    = "Allow"
  }

  statement {
    actions   = ["kms:GenerateDataKey", "kms:Decrypt"]
    resources = [aws_kms_key.this.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "results_read_write" {
  name        = "${aws_s3_bucket.results.name}-read-write"
  description = "Policy allowing read/write access to the performance testing results bucket"
  policy      = data.aws_iam_policy_document.results_read_write.json
}

resource "aws_iam_role_policy_attachment" "results_read_write" {
  role       = aws_iam_role.task.name
  policy_arn = aws_iam_policy.results_read_write.arn
}

resource "aws_iam_policy" "artillery_run_fargate" {
  name        = "artillery-run-fargate"
  description = "Policy allowing permissions necessary for artillery to run tests on a fargate cluster"
  policy      = data.aws_iam_policy_document.artillery_run_fargate.json
}

resource "aws_iam_role_policy_attachment" "artillery_run_fargate" {
  role       = aws_iam_role.task.name
  policy_arn = aws_iam_policy.artillery_run_fargate.arn
}