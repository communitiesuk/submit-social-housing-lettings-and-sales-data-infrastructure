# Development and Release processes

## Dev Process

### For small changes

* Create a branch off main for your changes
* Make your changes
* Merge to the dev branch and push
* Apply your changes to **staging** by running `terraform apply` from `terraform/staging` locally (in a console with your dluhc profile) - make sure the plan only includes changes you expect
* Try out your changes on staging
* When happy, raise a PR from your branch to main and get a technical review
* Get someone to do some testing/PO review on staging (exactly what form this applies in will depend on the ticket, and this might not be needed for some types of ticket)
* Merge your PR to main
* Apply the changes in main to development/shared
* Apply the changes in main to production
* If there is no parallel work going on, reset dev to match main. Otherwise, merge main into dev.

### For large changes

This might just follow the above process, but for larger changes there may be risks of getting in the way of the staging environment working (for example). Consider if you need to spin up a temporary environment in a new workspace while doing development on your change.

### Backwards compatibility

Note that when releasing changes we're always going to end up releasing an infrastructure change before any related application change.

This means that infrastructure changes need to be backwards compatible - this is most likely to apply to e.g. changing environment variables or other changes to containers.

You may need to structure some changes in two parts to allow for this.

## Releasing

As seen in the dev process instructions, infrastructure releases are currently manual (except for the per-review-app stuff).

We expect to make this automated (or at least less manual) at some point, certainly for the development environment and probably for the others.

To release an infrastructure change;

1. In a terminal, use e.g. `aws-vault exec dluhc` to get a shell logged in to your main AWS profile - see [development setup](./development_setup.md#set-up-aws-vault--cli)
1. Navigate to the relevant entrypoint module;
    * `terraform/development/shared` for the shared parts of the dev/review environment
    * `terraform/staging` for the staging environment
    * `terraform/production` for the production environment
1. Run `terraform apply`. This will start by showing you a plan of what terraform will attempt to change - check that this plan matches your expectations before allowing it to continue, e.g. it's not dropping and recreating anything unusual (particularly if it's something a DNS record points at, or that stores data), you recognise all the changes etc. If you're happy, give it confirmation and it will proceed.
1. Keep an eye out for any problems, particularly if changes are taking a while to complete.