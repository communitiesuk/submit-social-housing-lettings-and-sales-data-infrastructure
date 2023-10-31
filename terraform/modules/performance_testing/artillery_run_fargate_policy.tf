# See https://www.artillery.io/docs/load-testing-at-scale/aws-fargate#iam-permissions
data "aws_iam_policy_document" "artillery_run_fargate" {
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:GetRole"
    ]
    resources = [
      "arn:aws:iam::815624722760:role/artilleryio-ecs-worker-role"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:CreatePolicy",
      "iam:AttachRolePolicy"
    ]
    resources = [
      "arn:aws:iam::815624722760:policy/ecs-worker-policy"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    resources = [
      "arn:aws:iam::*:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS*"
    ]
    condition {
      test     = "StringLike"
      values   = ["ecs.amazonaws.com"]
      variable = "iam:AWSServiceName"
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::815624722760:role/artilleryio-ecs-worker-role"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:*"
    ]
    resources = [
      "arn:aws:sqs::815624722760:artilleryio*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["sqs:ListQueues"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:ListClusters",
      "ecs:CreateCluster",
      "ecs:RegisterTaskDefinition",
      "ecs:DeregisterTaskDefinition",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:DescribeClusters",
      "ecs:ListContainerInstances"
    ]
    resources = [
      "arn:aws:ecs::815624722760/cluster/*"
    ]
  }

  statement {
    sid    = "ECSPermissionsScopedWithCondition"
    effect = "Allow"
    actions = [
      "ecs:SubmitTaskStateChange",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:ListTaskDefinitions",
      "ecs:DescribeTaskDefinition",
      "ecs:StartTask",
      "ecs:StopTask",
      "ecs:RunTask"
    ]
    resources = ["*"]

    condition {
      test     = "ArnEquals"
      values   = ["arn:aws:ecs::815624722760:cluster/*"]
      variable = "ecs:cluster"
    }

  }

  statement {
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketPolicy",
      "s3:GetBucketTagging",
      "s3:PutBucketPolicy",
      "s3:PutBucketTagging",
      "s3:PutMetricsConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:PutLifecycleConfiguration"
    ]
    resources = [
      "arn:aws:s3:::artilleryio-test-data-*",
      "arn:aws:s3:::artilleryio-test-data-*/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "arn:aws:secretsmanager::815624722760:secret:artilleryio/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:PutParameter",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:DeleteParameter",
      "ssm:DescribeParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:eu-west-1:815624722760:parameter/artilleryio/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeRouteTables",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets"
    ]
    resources = ["*"]
  }
}