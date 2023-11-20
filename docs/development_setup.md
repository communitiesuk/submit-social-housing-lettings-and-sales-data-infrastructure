# Development Setup

To be set up for development on this infrastructure, you will need;
1. To install terraform and various linting / static analysis checkers
1. To have access to the AWS accounts, and set up to do so via the cli

## Install required software

You will need to install the following packages on your machine. Ideally, install the exact same version, but if not 
possible the exact same minor version should also be fine. How they are installed will depend on your type of machine,
see instructions below.

- [Terraform](https://github.com/hashicorp/terraform) _v1.5.2_
- [AWS CLI](https://github.com/aws/aws-cli) _v2.12.6_
- [AWS Vault](https://github.com/99designs/aws-vault) _v7.2.0_
- [TFLint](https://github.com/terraform-linters/tflint) _v0.47.0_
- [tfsec](https://github.com/aquasecurity/tfsec) _v1.28.1_
- [Checkov](https://github.com/bridgecrewio/checkov) _v2.3.329_

The following package managers are recommended to help install the required packages for developers;

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

### Windows
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

### Mac
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

## Set up AWS Vault / CLI

As this requires multiple accounts, we are using [AWS Vault](https://github.com/99designs/aws-vault) to simplify storing and using AWS credentials while doing local development.

You'll probably want to configure profiles for all accounts.

1. Go to the AWS console and log into the main DLUHC (mhclg) account as your user. Once there, go to the `My security credentials` page of `AWS IAM` and create an `Access key`, noting down both `access key id` itself and the `secret access key` given to you. While there, also look up your mfa_serial.
1. In your terminal, run `aws-vault add dluhc` and enter the access key id and secret access key as requested
1. If you are using a Mac you may be prompted to store the credentials in a Keychain - if so it's recommended that you create a custom keychain (in the Keychain Access app) called `aws-vault` to store the keychain item in. When creating the item (which will get a name like `aws-vault (dluhc)`) you will need to generate a password. It's recommended that you store this password somewhere secure, e.g. also in Keychain (but not in your new `aws-vault` custom keychain, since then you'd be storing the password inside what the password is for), or in Keeper or an equivalent secrets manager.
1. Open your `~/.aws/config` file. Update the `[profile dluhc]` section to add your mfa serial, and (optionally) default region and output settings;
    ```
    [profile dluhc]
    mfa_serial=arn:aws:iam::<DLUHC-ACCOUNT-ID>:mfa/<IAM-USERNAME>
    region=eu-west-2
    output=json
    ```
1. To create other profiles for each account (meta, development, staging, and production), you can add to this file e.g. 
    ```
    [profile dluhc-meta]
    source_profile=dluhc
    mfa_serial=arn:aws:iam::<DLUHC-ACCOUNT-ID>:mfa/<IAM-USERNAME>
    role_arn=arn:aws:iam::<META-ACCOUNT-ID>:role/<ROLE-NAME>
    ```
    This should automatically use the same credentials - annoyingly repeating the mfa_serial in the config is necessary.
1. You can now run e.g. `aws-vault exec dluhc` to launch an aws-vault subshell which uses the `dluhc` profile/credentials you just set up. When running this command, you will probably asked to enter your MFA code (you will unless you've recently had a session open that hasn't yet expired). If you are a Windows user, you may need to run the command `aws-vault exec dluhc -- bash` or `aws-vault exec dluhc -- powershell` in order to get aws-vault to open a subshell without erroring.