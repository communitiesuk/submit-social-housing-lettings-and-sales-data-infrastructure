# See https://www.artillery.io/docs/load-testing-at-scale/aws-fargate#iam-permissions
data "aws_iam_policy_document" "artillery_run_fargate" {
  statement {
    sid    = "CreateOrGetECSRole"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:GetRole"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/artilleryio-ecs-worker-role"
    ]
  }

  statement {
    sid    = "CreateECSPolicy"
    effect = "Allow"
    actions = [
      "iam:CreatePolicy",
      "iam:AttachRolePolicy"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ecs-worker-policy"
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
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/artilleryio-ecs-worker-role"
    ]
  }

  statement {
    sid    = "SQSPermissions"
    effect = "Allow"
    actions = [
      "sqs:*"
    ]
    resources = [
      "arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:artilleryio*"
    ]
  }

  statement {
    sid       = "SQSListQueues"
    effect    = "Allow"
    actions   = ["sqs:ListQueues"]
    resources = ["*"]
  }

  statement {
    sid    = "ECSPermissionsGeneral"
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
    sid    = "ECSPermissionsScopedToCluster"
    effect = "Allow"
    actions = [
      "ecs:DescribeClusters",
      "ecs:ListContainerInstances"
    ]
    resources = [
      "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}/cluster/*"
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
    condition {
      test     = "ArnEquals"
      values   = ["arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:cluster/*"]
      variable = "ecs:cluster"
    }
    resources = ["*"]
  }

  statement {
    sid    = "S3Permissions"
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
      "arn:aws:secretsmanager:*:${data.aws_caller_identity.current.account_id}:secret:artilleryio/*"
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
      "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/artilleryio/*"
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