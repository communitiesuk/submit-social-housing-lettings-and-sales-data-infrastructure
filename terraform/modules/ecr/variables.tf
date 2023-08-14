variable "accessible_from_accounts" {
  type        = list(string)
  description = "AWS account ids for the accounts requiring access to the repository"
}