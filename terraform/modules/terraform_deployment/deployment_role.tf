# This is a temporary measure, we will restrict permissions further later
# See CLDC-2820
data "aws_iam_policy" "developer_power_user" {
  name = "developer-poweruser-policy"
}

data "aws_iam_policy_document" "terraform_deployment_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.assume_from_role_arns
    }
  }
}

resource "aws_iam_role" "terraform_deployment" {
  name               = "${var.prefix}-terraform-deployment"
  assume_role_policy = data.aws_iam_policy_document.terraform_deployment_assume_role.json
}

resource "aws_iam_role_policy_attachment" "terraform_deployment_developer" {
  role       = aws_iam_role.terraform_deployment.name
  policy_arn = data.aws_iam_policy.developer_power_user.arn
}