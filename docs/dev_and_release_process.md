# Development and Release processes

## Dev Process

### For small changes

* Create a branch off main for your changes
* Make your changes
* Merge to the dev branch and push - dev is a long running branch, but there's no need to create PR for this
* Apply your changes to **staging** by running `terraform apply` from `terraform/staging` locally (in a console with your mhclg profile) - make sure the plan only includes changes you expect
* Try out your changes on staging
* When happy, raise a PR from your branch to main and get a technical review
* Get someone to do some testing/PO review on staging (exactly what form this applies in will depend on the ticket, and this might not be needed for some types of ticket)
* Merge your PR to main
* Apply the changes in main to development/shared
* Apply the changes in main to production
* If there is no parallel work going on, reset dev to match main. Otherwise, merge main into dev.

#### Why the dev branch?

If there are people working in parallel on infrastructure changes, we need a way for you both to be able to apply changes during the development process without overwriting each others work - hence pushing to dev and applying from there.

This is kept separate from your working branches to keep the changes separated, so that e.g. you can do PRs into main for review that have only your changes.

Similarly if there's one person and multiple branches for any reason.

Things don't need review to go here because you probably need to apply your work as part of development before having things finished or ready for code review. For small changes and the staging environment we're happy for terraform to be applied this way, but if there's something you're unsure about then do ask for a review / some pairing before applying or to look at the terraform plan. And do think about cost before applying, i.e. make sure you're not creating larger infra than necessary.

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

1. In a terminal, use e.g. `aws-vault exec mhclg` to get a shell logged in to your main AWS profile - see [development setup](./development_setup.md#set-up-aws-vault--cli)
1. Navigate to the relevant entrypoint module;
    * `terraform/development/shared` for the shared parts of the dev/review environment
    * `terraform/staging` for the staging environment
    * `terraform/production` for the production environment
1. Run `terraform apply`. This will start by showing you a plan of what terraform will attempt to change - check that this plan matches your expectations before allowing it to continue, e.g. it's not dropping and recreating anything unusual (particularly if it's something a DNS record points at, or that stores data), you recognise all the changes etc. If you're happy, give it confirmation and it will proceed.
1. Keep an eye out for any problems, particularly if changes are taking a while to complete.

### Releasing changes to ECS container/task definitions

These changes are ignored by default in our terraform, because the process for releasing updated application versions changes them.

To release such a change, you'll need to temporarily remove the ignore changes instructions locally - which means you'll need to set whatever the current image is so that you're not accidentally changing that as well.

To do this;

1. Ensure there are no code releases currently in progress / due to happen while you're doing this
1. In the relevant aws account context for the environment, run `aws ecs describe-task-definition --task-definition core-ENV-app --query taskDefinition.containerDefinitions[0].image` (replacing ENV with staging or prod as appropriate) to get the currently in use image definition
1. In `modules/application/ecs.tf`;
    1. Update the value of "image" in the second locals block to the result of the previous step
    1. Remove the `ignore_changes = [container_definitions]` line from each of the app, sidekiq, and ad_hoc task definitions
    1. Remove the `ignore_changes = [task_definition]` line from each of the app and sidekiq services
1. In the main aws account context, run terraform apply from the relevant entrypoint (as you would for any other release). In addition to any other changes you are releasing, the terraform plan should include  3 to add, 3 to change, 3 to destroy;
    * Update the app service task_definition
    * Update the sidekiq service task_definition
    * Replace each of the 3 task definitions
    * Update the `run_ecs_task_and_update_service` iam policy in place (as this relies on reading outputs that might have changed)

You can discard your local changes once the apply is done.

Note that there is normally no need to do this for review apps, unless there is a specific long running review app that needs the update - as soon as the change is merged to main any new review apps will use the updated definitions, and it's usually ok to leave existing ones on the old version.