# submit-social-housing-lettings-and-sales-data-infrastructure
Infrastructure repository for the service for submitting social housing lettings and sales data (CORE)

## Terraform state remote backend setup
Before starting to create any infrastructure on an AWS account, a developer will need to do a one-time setup of the remote "backend" for terraform state management

We use the `cloudposse` module in `main.tf` to help set this up. General instructions for the module can be found [here](https://github.com/cloudposse/terraform-aws-tfstate-backend#usage) if required, however please follow the steps below for our use case:

1. Tun `terraform init` for the desired AWS account. This will automatically create a `backend.tf` config file at the root of the repo. Commit this file if it has not been already (it should be the same for all AWS accounts)

2. Run `terraform apply`. This will create the backend config, S3 bucket, DynamoDB for the desired AWS account

3. Now run `terraform init` again. It should ask if you want to copy over the state file (from local to the backend), type in `yes`. This will manage changes to the S3 bucket and DyanamoDB used for state management itself, as well as the general infrastructure. You are now ready to develop the infrastructure!
