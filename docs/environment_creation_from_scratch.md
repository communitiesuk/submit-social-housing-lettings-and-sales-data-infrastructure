# Creating a new environment from scratch

When setting up a new environment:
1. DNS records will need to be created by DLUHC for certificate validation and to point at the cloudfront distribution and app load balancer
1. Secret values will need to be filled in manually
1. The meta account will need updating with additional roles access to the ecr, since this is currently manual
1. A new deployment pipeline will need to be setup

## The process

### Run an initial apply

```terraform apply -target="module.networking" -target="module.front_door" -target="module.certificates" --target="module.application_roles" --target="module.application_secrets" var="initial_create=true"```

(Need the networking explicitly otherwise we get an error creating the load balancer, there's some kind of dependency that terraform doesn't quite get)

This will create the certificates, load balancer, cloudfront distribution, and some networking and other things needed for defining DNS records.
It will also create some app roles and secrets which are necessary before creating the full app.

### Get DNS Records set up

Ask DLUHC to set up DNS records required.

This will be;
* Validation for the cloudfront certificate
* Validation for the load balancer certificate
* CNAME for the cloudfront domain pointing at the cloudfront distribution
* CNAME for the load balancer domain pointing at the load balancer

Once DLUHC has set up the records, check the certificates have been validated in AWS console.

### Fill the application secrets

When doing a full apply the complete application will be created, and will need to be able to read secrets. 
Fill out the values for the secrets in AWS console before the full apply.

### Update meta environment

In the [meta/main.tf](../terraform/meta/main.tf) file, add the ARN of the task-execution role from the newly created environment to the ECR module's `allow_access_by_roles` parameter

### Run a full apply

Once these have been done, run a complete apply

### Set up the database

If not restoring the database from a backup, or migrating it from elsewhere, run the db:setup rake task (use the ad_hoc task definition to spin it up from the app image with a command override).

Alternatively you probably need to run an app deployment to sort out using the right image, which will include a db migration - you can then just run db:seed as a separate task.

### Set up the deployment

In the Core App codebase [here](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data), you will need create a new pipeline for the environment (you can re-use jobs and configuration in existing pipelines where appropriate)
For the `aws_deploy` workflow, ensure you pass in the new account id, resource prefix and environment name