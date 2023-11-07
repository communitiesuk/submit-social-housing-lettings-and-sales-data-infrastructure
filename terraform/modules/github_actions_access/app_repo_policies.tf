data "aws_iam_policy_document" "push_images" {
  statement {
    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:ListImages"
    ]
    resources = [var.ecr_arn]
    effect    = "Allow"
  }

  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "push_images" {
  name   = "core-ecr-push-images"
  policy = data.aws_iam_policy_document.push_images.json
}

resource "aws_iam_role_policy_attachment" "app_repo_push_images" {
  role       = aws_iam_role.repo["application"].name
  policy_arn = aws_iam_policy.push_images.arn
}