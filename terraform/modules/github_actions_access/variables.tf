variable "meta_account_id" {
  type        = string
  description = "Account id for the meta account"
}

variable "repositories" {
  type = map(object(
    {
      name = string,
      policies = list(object(
        {
          key = string
          arn = string
        }
      ))
    }
  ))
  description = "For each repository, the owner/repo-name and list of policies to apply to the role accessible by that repo with arn and a readable reference"
}