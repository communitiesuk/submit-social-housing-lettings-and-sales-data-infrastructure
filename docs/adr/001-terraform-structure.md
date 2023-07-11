# Terraform structure

## Status

Draft

## Environment Entrypoint Modules

We will use separate modules as entrypoints for the dev, staging, and production environments. These will reference shared modules which define the infrastructure. Within the dev environment, we will use terraform workspaces for separate instances.

Pros:
* Easy to set and see differences between environments
* Hard to accidentally be in the wrong environment when running terraform for staging / prod
* As each of dev, staging, and production will be in separate AWS accounts, this should reduce set up complexity and make it easier to reason about
* Reusable modules referenced by each environment is good practice for code organisation reasons and ensures we are not duplicating more than necessary

Cons:
* Potential for lots of duplication between the terraform files in each entrypoint

Alternatives considered:
* Could use workspaces to do everything, with some cleverness required to act on different accounts.

## Terraform state in the meta/CI account

Terraform state will be stored for each entrypoint in a bucket in the meta/CI account.

Pros:
* Separation between service infrastructure and terraform setup

Cons:
* May add complexity to terraform backend setup / permissions & roles required for running terraform

Alternatives considered:
* Could put state in the relevant account for each environment

## Meta terraform module for infra in the CI account

We will have a separate terraform module that sets up infra in the meta/CI account. This includes the definitions of an s3 bucket and other infra needed for storing terraform state.

Pros:
* Defined record of what exists
* Easy to recreate in a disaster scenario

Cons:
* Mild initial set up faff for the part that creates the infrastructure for storing terraform state

Alternatives: 
* Could set up the infra for terraform state manually to avoid needing to create initially with local backend and then move over