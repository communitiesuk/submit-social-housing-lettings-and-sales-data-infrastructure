# submit-social-housing-lettings-and-sales-data-infrastructure
Infrastructure repository for the service for submitting social housing lettings and sales data (CORE)

## Zero to Hero
Depending on your type of machine, the following package managers are recommended to help install the required packages
for developers

Windows:
- `chocolatey` - [see installation instructions](https://chocolatey.org/install#individual)
- `pip3` - this is typically included by default when you install `Python3.4+`, so ensure you have a suitable python 
version installed on your machine. You can use [pyenv for windows](https://github.com/pyenv-win/pyenv-win) or a 
[python installer](https://www.python.org/downloads/) for this

Mac:
- `homebrew` - [see installation instructions](https://brew.sh/)

### Installing Packages
You will need to install the following packages on your machine. Ideally, install the exact same version, but if not 
possible the exact same minor version should also be fine. How they are installed will depend on your type of machine, 
see below.

- [terraform](https://github.com/hashicorp/terraform) _v1.5.2_  
- [aws cli](https://github.com/aws/aws-cli) _v2.12.6_  
- [tflint](https://github.com/terraform-linters/tflint) _v0.47.0_  
- [tfsec](https://github.com/aquasecurity/tfsec) _v1.28.1_  
- [checkov](https://github.com/marketplace/actions/checkov-github-action) _v2.3.311_

#### Windows

Check if you have any of the packages already installed and which version by either:
- finding and opening the `chocolatey GUI` program
- using the `choco list` or `choco list <packagename>` commands (package names can be found in the `install` commands 
below)

If you don't have the package installed already, you can run the desired install command from the list below:
- `choco install terraform --version 1.5.2`
- `choco install awscli --version 2.12.6`
- `choco install tflint --version 0.47.0`
- `choco install tfsec --version 1.28.1`
- `pip3 install checkov`

If it's already installed and is an older version, you can upgrade it using:
- `choco upgrade <packagename> --version x.y.z`

If it's newer and undesired or you need to do a clean install due to issues, you can `uninstall` first using:
- `choco uninstall <packagename> --version x.y.z` to remove the version
- then run the desired `choco install` command from above

If at any point you don't want to target a specific version / get the latest version, you can omit `--version x.y.z` 
from the commands above

#### Macs 

Check if you have any of the packages already installed and which version by using the command:
- `brew list --versions`

If you don't have the package installed already, you can run the desired install command from the list below:
- `brew install terraform@1.5.2`  
- `brew install awscli@2.12.6`  
- `brew install tflint@0.47.0`  
- `brew install tfsec@1.28.1`  
- `brew install checkov@v2.3.311`

If it's already installed and you want to uninstall any outdated versions, plus clear download caches, you can run the 
following command:
- `brew cleanup <packagename>`

If it's newer and undesired or you need to do a clean install due to issues, you can `uninstall` first using:
- `brew uninstall <packagename>` or `brew remove <packagename>` to uninstall all versions of that package
- then run the desired `brew install` command from above

- If at any point you don't want to target a specific version / get the latest version, you can omit the `@x.y.z`
from the command

## Terraform state remote backend setup
Before starting to create any infrastructure on the meta, development, staging or production accounts, a developer will 
need to complete a one-time setup of the remote "backend" for Terraform state management by "bootstrapping".

We use the `cloudposse` module in [meta/main.tf](./terraform/meta/main.tf) to help set this up. General instructions for 
the module can be found [here](https://github.com/cloudposse/terraform-aws-tfstate-backend#usage) if necessary, however 
please follow the steps below for our use case:

1. Ensure your machine is set up to use the credentials of the Meta AWS account (e.g. by configuring the AWS CLI, using 
AWS-Vault or otherwise)

2. `cd` into the `meta` folder and open the [[meta/main.tf] file. Ensure that the whole `backend "s3"` section in the 
`terraform` codeblock is commented out for the time-being

3. Now run the `terraform init` command

3. Now run `terraform apply`. This will create two sets of backend configuration (in terms of an S3 bucket and DynamoDB 
for terraform state management), one set for all the non-production accounts, and one set just for the production 
account. It will also create two separate S3 buckets for access logging and replication for each set

4. Now undo the commenting out of the whole `backend "s3"` as was instructed in step 2

5. Now run `terraform init` again. It should ask if you want to copy over the state file (from local to the backend), 
type in `yes`. Once complete, the state management is now setup for all accounts and you can begin to work on the 
infrastructure
