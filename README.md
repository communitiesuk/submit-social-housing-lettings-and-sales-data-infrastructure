# submit-social-housing-lettings-and-sales-data-infrastructure

Infrastructure repository for the service for submitting social housing lettings and sales data (CORE).

This contains terraform code defining our infrastructure in each environment.

## Development

### Getting Started

[See development setup instructions](./docs/development_setup.md) for first time setup.

### Codebase info

We have several entrypoint modules, corresponding to different environments. `terraform/production` is our production env. `terraform/staging` is our staging env. `terraform/meta` is our meta env, which doesn't run an app instance but is used for docker images, CI/CD related things, and anything that's not environment specific. `terraform/development` relates to things in our development account, which is split into two parts: `shared` and `per_review_app`. Review apps (which run in this account) share a number of pieces of infrastructure (e.g. networking, database cluster) defined in the `shared` module, and spin up their own instances of those things defined in the `per_review_app` module.

The entrypoint modules use the re-usable modules from the `terraform/modules` folder in order to be defining the same bits of infrastructure in different envs (but, as you'll see comparing the entrypoint modules) with slightly different settings.

### Using static analysis tools
While developing the codebase, you can run the tools below locally to check the Terraform using the commands below. 
The Terraform pipeline also makes use of these same tools.

#### Terraform
##### terraform fmt
- Make sure you are at the root of the codebase to check all files.
- Run `terraform fmt -recursive` - this checks the formatting of all terraform files in the current directory and all 
  its subdirectories.

##### terraform validate
- Make sure you are at the root of the `meta`, `development`, `staging` or `production` folders to check whole environments. Alternatively you can be at the root of a folder in `modules`, if you just want to validate a specific module.
- Make sure that you have run `terraform init` in your chosen folder.
- `terraform validate` - runs checks that verify whether a configuration is syntactically valid and internally 
  consistent, regardless of any provided variables or existing state. It is thus primarily useful for general 
  verification of reusable modules, including correctness of attribute names and value types.

#### tflint
- Make sure you are at the root of the codebase to check all files and initialise the plugins.
- `tflint --init` - this will install any plugins defined in the [.tflint.hcl](.tflint.hcl) configuration file.
- `tflint --recursive --config "$(pwd)/.tflint.hcl" --format=compact --color` - this will check the terraform files 
  against a rule set for AWS, mainly to find possible errors (such as incorrect instance types), warn about 
  deprecated syntax and unused declarations, and to enforce best practices and naming conventions.

#### tfsec
- Make sure you are at the root of the codebase to check all files.
- `tfsec` - this will complete a static analysis security scan of the terraform code.
- On Windows machines, ensure you use this command in terminal run as an administrator! Otherwise, it will not 
  complete all the checks it should and the result will be unreliable.

#### checkov
- Make sure you are at the root of the codebase to check all files.
- `checkov --quiet --download-external-modules true --directory .` - this will scan and check for any 
  misconfigurations in our terraform.

#### A note about external modules
- We use [Cloud Posse](https://github.com/cloudposse) `tfstate-backend` and `s3-bucket` modules in
  [modules/backend/main.tf](terraform/modules/backend/main.tf) to help set up the backend. Be aware, that the source 
  code of these external modules contain statements to ignore certain `tfesc` and `checkov` rules that would 
  otherwise be flagged. In general these ignore rules look sensible given how these modules are designed.