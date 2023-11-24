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

#tfsec:ignore:aws-iam-no-policy-wildcards - do want actions to apply to all items in bucket
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
  name        = "${aws_s3_bucket.results.bucket}-read-write"
  description = "Policy allowing read/write access to the performance testing results bucket"
  policy      = data.aws_iam_policy_document.results_read_write.json
}

resource "aws_iam_role_policy_attachment" "results_read_write" {
  role       = aws_iam_role.task.name
  policy_arn = aws_iam_policy.results_read_write.arn
}

# See https://www.artillery.io/docs/load-testing-at-scale/aws-fargate#iam-permissions
# I couldn't get a data resource to work for unknown reasons, so this is copied from there with the account id updated (and non eu-west-1 regions removed)
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "artillery_run_fargate" {
  #checkov:skip=CKV_AWS_290
  name        = "artillery-run-fargate"
  description = "Policy allowing permissions necessary for artillery to run tests on a fargate cluster"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "CreateOrGetECSRole",
        "Effect" : "Allow",
        "Action" : [
          "iam:CreateRole",
          "iam:GetRole"
        ],
        "Resource" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/artilleryio-ecs-worker-role"
      },
      {
        "Sid" : "CreateECSPolicy",
        "Effect" : "Allow",
        "Action" : [
          "iam:CreatePolicy",
          "iam:AttachRolePolicy"
        ],
        "Resource" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ecs-worker-policy"
      },
      # Allow Artillery CLI to create AWS service role for ECS when creating a Fargate cluster
      # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using-service-linked-roles.html#create-service-linked-role
      {
        "Effect" : "Allow",
        "Action" : ["iam:CreateServiceLinkedRole"],
        "Resource" : [
          "arn:aws:iam::*:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS*"
        ],
        "Condition" : {
          "StringLike" : {
            "iam:AWSServiceName" : "ecs.amazonaws.com"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : ["iam:PassRole"],
        "Resource" : ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/artilleryio-ecs-worker-role"]
      },
      {
        "Sid" : "SQSPermissions",
        "Effect" : "Allow",
        "Action" : [
          "sqs:*"
        ],
        "Resource" : "arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:artilleryio*"
      },
      {
        # ListQueues cannot be scoped to individual resources
        # https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonsqs.html#amazonsqs-queue
        "Sid" : "SQSListQueues",
        "Effect" : "Allow",
        "Action" : [
          "sqs:ListQueues"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "ECSPermissionsGeneral",
        "Effect" : "Allow",
        "Action" : [
          "ecs:ListClusters",
          "ecs:CreateCluster",
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "ECSPermissionsScopedToCluster",
        "Effect" : "Allow",
        "Action" : [
          "ecs:DescribeClusters",
          "ecs:ListContainerInstances"
        ],
        "Resource" : "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:cluster/*"
      },
      {
        "Sid" : "ECSPermissionsScopedWithCondition",
        "Effect" : "Allow",
        "Action" : [
          "ecs:SubmitTaskStateChange",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:ListTaskDefinitions",
          "ecs:DescribeTaskDefinition",
          "ecs:StartTask",
          "ecs:StopTask",
          "ecs:RunTask"
        ],
        "Condition" : {
          "ArnEquals" : {
            "ecs:cluster" : "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:cluster/*"
          }
        },
        "Resource" : "*"
      },
      {
        "Sid" : "S3Permissions",
        "Effect" : "Allow",
        "Action" : [
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
        ],
        "Resource" : [
          "arn:aws:s3:::artilleryio-test-data-*",
          "arn:aws:s3:::artilleryio-test-data-*/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : ["secretsmanager:GetSecretValue"],
        "Resource" : ["arn:aws:secretsmanager:*:${data.aws_caller_identity.current.account_id}:secret:artilleryio/*"]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:PutParameter",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:DeleteParameter",
          "ssm:DescribeParameters",
          "ssm:GetParametersByPath"
        ],
        "Resource" : [
          "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/artilleryio/*",
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets"
        ],
        "Resource" : ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "artillery_run_fargate" {
  role       = aws_iam_role.task.name
  policy_arn = aws_iam_policy.artillery_run_fargate.arn
}