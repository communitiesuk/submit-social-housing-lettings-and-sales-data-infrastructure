# submit-social-housing-lettings-and-sales-data-infrastructure
Infrastructure repository for the service for submitting social housing lettings and sales data (CORE)

## Terraform state remote backend setup
Before starting to create any infrastructure on the meta, development, staging or production accounts, a developer will 
need to complete a one-time setup of the remote "backend" for terraform state management by "bootstrapping"

We use the `cloudposse` module in `meta/main.tf` to help set this up. General instructions for the module can be found 
[here](https://github.com/cloudposse/terraform-aws-tfstate-backend#usage) if required, however please follow the steps 
below for our use case:

1. Ensure your machine is set up to use the credentials of the Meta AWS account (e.g. by configuring the AWS CLI, 
using AWS-Vault or otherwise)

2. Cd into the `meta` folder and run the `terraform init` command 

3. Now run `terraform apply`. This will create two sets of backend configuration in terms of S3 buckets and DynamoDBs, 
one set for all the non-production accounts, and one set just for the production account. 
It will also automatically create a `backend_non_production.tf` and `backend_production.tf` config files at the root of
the folder which will need to keep for reference later

4. Now run `terraform init` again. It should ask if you want to copy over the state file (from local to the backend), 
type in `yes`. Once complete, the state management is now setup for all accounts and we can begin to work on the
infrastructure

## WIP Zero to Hero
### terraform

### aws cli

### tflint
Link to repo and install instructions, as well as github-actions recommendation, see [here](https://github.com/terraform-linters/tflint)

### tfsec
Link to repo and install instructions, see [here](https://github.com/aquasecurity/tfsec)
Link to github actions useful info, see [here](https://github.com/terraform-linters/tflint/blob/master/docs/user-guide/plugins.md#avoiding-rate-limiting)

### checkov
Link to repo and install instructions, see [here](https://github.com/marketplace/actions/checkov-github-action)