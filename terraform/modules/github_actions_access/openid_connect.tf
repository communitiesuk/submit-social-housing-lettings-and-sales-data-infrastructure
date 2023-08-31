resource "aws_iam_openid_connect_provider" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = ["1C58A3A8518E8759BF075B76B750D4F2DF264FCD"]
}