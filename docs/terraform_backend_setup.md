# Terraform state remote backend setup

Before starting to create any infrastructure on the `meta`, `development`, `staging` or `production` accounts, a
developer will need to complete a one-time setup of the remote "backend" for Terraform state management by
"bootstrapping".

We use the [Cloud Posse](https://github.com/cloudposse) `tfstate-backend` and `s3-bucket` modules in
[modules/backend/main.tf](terraform/modules/backend/main.tf) to help set this up. General instructions for
the module can be found [here](https://github.com/cloudposse/terraform-aws-tfstate-backend#usage) if necessary, however
please follow the steps below for our use case:

1. Ensure your machine is set up to use the credentials of your MHCLG profile / account (using `AWS Vault` is
   recommended).


2. `cd` into the [terraform/meta](terraform/meta) folder and open the [main.tf](terraform/meta/main.tf) file. Ensure
   that the whole `backend "s3"` section in the `terraform` block is commented out for the time-being.


3. Run the `terraform init` command.


3. Run `terraform apply`. This will create two sets of backend configuration (an `S3 bucket` and `DynamoDB` for
   terraform state management), one for all the non-production accounts, and one just for the production
   account. This will also create separate S3 buckets for access logging and replication in each.


4. Undo step 2 i.e. make sure the `backend "s3"` block is no longer commented out.


5. Finally run `terraform init` again. It should ask if you want to copy over the state file (from local to the
   backend), type in `yes` when prompted. Once complete, the state management is now setup for all accounts and you
   can begin to work on the infrastructure.