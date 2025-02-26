# Github workflows and deployments

## Terraform Checks

This workflow currently runs on PRs, and runs several terraform static checks;
* terraform fmt (everywhere)
* terraform validate (on each entrypoint module)
* tflint (everywhere)
* tfsec (everywhere)
* checkov (everywhere)

It must pass before a PR can be merged to main

## Review apps

Review apps are deployed in our development account. Some infrastructure is shared between review apps (see the `development/shared` module), others parts are spun up per-review-app (see `development/per_review_app`).

This repository contains two workflows relating to the per-review-app infrastructure, `create_review_app_infra` and `destroy_review_app_infra`. These will automatically create / destroy the per-review-app infra for a specific review app.

Instead of being run in this repository, they are pulled and run by the application repository when PRs are opened/syncronised/closed there (and the application repo is given the necessary permissions to create/destroy infra in the development account).

## Other deployments

Currently, all other infrastructure deployments must be done by manually applying terraform.

This might change in future, at least for the shared development infrastructure. 

To do so, use your aws cli profile for your main mhclg account (i.e. not having assumed a role in any of the application accounts), select the relevant entrypoint folder, and run `terraform apply`.

While doing so, confirm that the plan you see matches the changes you expect before approving it.

At the moment, the expectation is that;
* The production environment uses infra code from `main`
* The development environment uses infra code from `main`
* The staging and meta environments use infra code from `dev`

The `dev` branch is able to be merged to during development in order to make small changes to the staging and meta environments ahead of code review, although importantly;
1. We need to be careful with potentially breaking changes, particularly for the meta environment
1. We need to ensure that dev is returned to matching main when it is no longer needed

The point of the dev branch is to allow for testing changes potentially from multiple people, hence not just doing it from your feature branch