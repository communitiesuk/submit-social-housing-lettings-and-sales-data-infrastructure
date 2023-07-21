# submit-social-housing-lettings-and-sales-data-infrastructure
Infrastructure repository for the service for submitting social housing lettings and sales data (CORE).

## Zero to Hero
Depending on your type of machine, the following package managers are recommended to help install the required 
packages for developers.

Windows:
- `chocolatey` - [see installation instructions](https://chocolatey.org/install#individual).
- `pip3` - this is typically included by default when you install `Python 3.4+`, so ensure you have a suitable python
version installed on your machine. You can use [pyenv for windows](https://github.com/pyenv-win/pyenv-win) or a
[python installer](https://www.python.org/downloads/windows/) for this.

Mac:
- `homebrew` - [see installation instructions](https://brew.sh/).
- `pip3` - this is typically included by default when you install `Python 3.4+` using `homebrew`. Alternatively, you 
  can also use [pyenv](https://github.com/pyenv/pyenv) or a [python installer](https://www.python.org/downloads/macos/)
  for this.

### Installing Packages
You will need to install the following packages on your machine. Ideally, install the exact same version, but if not 
possible the exact same minor version should also be fine. How they are installed will depend on your type of machine,
see instructions below.

- [Terraform](https://github.com/hashicorp/terraform) _v1.5.2_
- [AWS CLI](https://github.com/aws/aws-cli) _v2.12.6_
- [AWS Vault](https://github.com/99designs/aws-vault) _v7.2.0_
- [TFLint](https://github.com/terraform-linters/tflint) _v0.47.0_
- [tfsec](https://github.com/aquasecurity/tfsec) _v1.28.1_
- [Checkov](https://github.com/bridgecrewio/checkov) _v2.3.329_

#### Windows
<details>
<summary>instructions</summary>

<br>
Check if you have any of the packages already installed and which version by either:
- finding and opening the `chocolatey GUI` program.
- using the `choco list` or `choco list <packagename>` commands (package names can be found in the `install` commands
below).

If you don't have the package installed already, you can run the desired install command from the list below:
- `choco install terraform --version 1.5.2`
- `choco install awscli --version 2.12.6`
- `choco install aws-vault --version 7.2.0`
- `choco install tflint --version 0.47.0`
- `choco install tfsec --version 1.28.1`
- `pip3 install checkov==2.3.329` (Due to inconsistencies in Checkov between different package managers, you should 
  only install it using pip3.)

If it's already installed and is an older version, you can upgrade it using:
- `choco upgrade <packagename> --version x.y.z`

If it's newer and undesired or you need to do a clean install due to issues, you can `uninstall` first using:
- `choco uninstall <packagename> --version x.y.z` to remove the version.
- then run the desired `choco install` command from above.

If at any point you don't want to target a specific version / get the latest version, you can omit `--version x.y.z`
from the commands above.

</details>

#### Macs
<details>
<summary>instructions</summary>

<br>
Check if you have any of the packages already installed and which version by using the command:
- `brew list --versions`

If you don't have the package installed already, you can run the desired install command from the list below:
- `brew install terraform@1.5.2`
- `brew install awscli@2.12.6`
- `brew install --cask aws-vault` (You are unable to easily specify the version of `aws-vault` to install using 
  `brew cask`, however the latest version should work fine. If you run into issues, you can try to ensure you install 
  _v7.2.0_ through `cask` by following the instructions on this [stack overflow post](https://stackoverflow.com/questions/58373704/homebrew-how-do-you-specify-a-version-using-brew-cask).)
- `brew install tflint@0.47.0`
- `brew install tfsec@1.28.1`
- `pip3 install checkov==2.3.329` (Due to inconsistencies in Checkov between different package managers, you should 
  only install it using `pip3`.)

If it's already installed and you want to uninstall any outdated versions, plus clear download caches, you can run the
following command:
- `brew cleanup <packagename>`

If it's newer and undesired or you need to do a clean install due to issues, you can `uninstall` first using:
- `brew uninstall <packagename>` or `brew remove <packagename>` to uninstall all versions of that package (add 
  `--cask` if the package was installed with `brew cask`).
- then run the desired `brew install` command from above.

If at any point you don't want to target a specific version / get the latest version, you can omit the `@x.y.z`
from the command.

</details>

## AWS Vault

We are using [AWS Vault](https://github.com/99designs/aws-vault) to simplify storing and using AWS credentials while 
doing local development.

Once installed, you will need to configure a dluhc profile as follows:

1. Find your `config` and `credentials` files in your `~/.aws/config` folder. If any of these don't exist, create them.


2. Add the following to your `config` file (filling in the AWS account ID of the main MHCLG account, and the 
   username created for you by MHCLG in this account):
```
[profile dluhc]
mfa_serial=arn:aws:iam::<MHCLG-ACCOUNT-ID>:mfa/<IAM-USERNAME>
region=eu-west-2
output=json
```

3. Go to the AWS console and log in as this user. Once there, go to the `My security credentials` page of `AWS IAM` 
   and create an `Access key`, noting down both `access key` itself and the `secret access key` given to you.


4. Add in the details from above to your `credentials` file in the following format:
```
[dluhc]
aws_access_key_id = ...
aws_secret_access_key = ...
``````

5. Run `aws-vault add dluhc` and enter the keys just added to your `credentials` file as requested.


6. If you are using a Mac you may be prompted to store the credentials in a Keychain - if so it's recommended that 
   you create a custom keychain (in the Keychain Access app) called `aws-vault` to store the keychain item in. When 
   creating the item (which will get a name like `aws-vault (dluhc)`) you will need to generate a password. It's 
   recommended that you store this password somewhere secure, e.g. also in Keychain (but not in your new `aws-vault` 
   custom keychain, since then you'd be storing the password inside what the password is for), or in Keeper or an 
   equivalent secrets manager.


7. You can then run `aws-vault exec dluhc` to launch an aws-vault subshell using the `dluhc` profile/credentials you 
   just set up. When running this command, you maybe asked to enter your MFA code (you will have setup MFA as part 
   of instructions sent to you by MHCLG for accessing your account). Then when you run Terraform commands (e.g. 
   `terraform apply`) you will automatically be acting as this user, without needing to enter your AWS credentials. 
   If you are a Windows user, you may need to run the command `aws-vault exec dluhc -- bash` or `aws-vault exec 
   dluhc -- powershell` in order to get aws-vault to open a subshell without erroring.


You can set up other profiles in a similar way (just using a name other than `dluhc`, configuring the profile as 
necessary in the `config` file, and entering the relevant credentials as necessary in the `credentials` file). You may 
need to do this if you want to complete actions directly on the `meta`, `development`, `staging` and `production` 
accounts. When creating your profiles for this in your `config` file, you will also need to put the `role_arn` to be 
assumed on that account, e.g.
```
[profile dluhc]
mfa_serial=arn:aws:iam::<DLUHC-ACCOUNT-ID>:mfa/<IAM-USERNAME>
role_arn=arn:aws:iam::<META-ACCOUNT-ID>:role/<ROLE-NAME>
region=eu-west-2
output=json
```

## Using tools
While developing the codebase, you can run the tools below locally to check the Terraform using the commands below. 
The Terraform pipeline also makes use of these same tools.

### Terraform
#### terraform fmt
- Make sure you are at the root of the codebase to check all files.
- Run `terraform fmt -recursive` - this checks the formatting of all terraform files in the current directory and all 
  its subdirectories.

#### terraform validate
- Make sure you are at the root of the `meta`, `development`, `staging` or `production` folders to check whole environments. Alternatively you can be at the root of a folder in `modules`, if you just want to validate a specific module.
- Make sure that you have run `terraform init` in your chosen folder.
- `terraform validate` - runs checks that verify whether a configuration is syntactically valid and internally 
  consistent, regardless of any provided variables or existing state. It is thus primarily useful for general 
  verification of reusable modules, including correctness of attribute names and value types.

### tflint
- Make sure you are at the root of the codebase to check all files and initialise the plugins.
- `tflint --init` - this will install any plugins defined in the [.tflint.hcl](.tflint.hcl) configuration file.
- `tflint --recursive --config "$(pwd)/.tflint.hcl" --format=compact --color` - this will check the terraform files 
  against a rule set for AWS, mainly to find possible errors (such as incorrect instance types), warn about 
  deprecated syntax and unused declarations, and to enforce best practices and naming conventions.

### tfsec
- Make sure you are at the root of the codebase to check all files.
- `tfsec` - this will complete a static analysis security scan of the terraform code.
- On Windows machines, ensure you use this command in terminal run as an administrator! Otherwise, it will not 
  complete all the checks it should and the result will be unreliable.

### checkov
- Make sure you are at the root of the codebase to check all files.
- `checkov --quiet --download-external-modules true --directory .` - this will scan and check for any 
  misconfigurations in our terraform.

### A note about external modules
- We use [Cloud Posse](https://github.com/cloudposse) `tfstate-backend` and `s3-bucket` modules in
  [modules/backend/main.tf](terraform/modules/backend/main.tf) to help set up the backend. Be aware, that the source 
  code of these external modules contain statements to ignore certain `tfesc` and `checkov` rules that would 
  otherwise be flagged. In general these ignore rules look sensible given how these modules are designed.