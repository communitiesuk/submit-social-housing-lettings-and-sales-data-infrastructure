# This is a temporary measure.
# This role is has duplicate permissions to the now-removed developer-superuser-policy, which was shared with developers on the project.
# We will restrict permissions further later to only those needed to deploy our terraform infrastructure.
# See CLDC-2820 & CLDC-4058.
data "aws_iam_policy" "developer_power_user" {
  name = "terraform-policy"
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