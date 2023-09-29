# Creating a new environment from scratch

TODO: Update this once splitting out secrets and app roles is done, add instructions for sorting those and things to update in meta.

When setting up a new environment;
1. DNS records will need to be created by DLUHC for certificate validation and to point at the cloudfront distribution and app load balancer
1. Secret values will need to be filled in manually
1. Need to set up deployments etc.
1. Need to ensure anything that needs adding to the meta module (e.g. for roles access to ecr) is done, since some of that is currently manual

## The process

### Run an initial apply

```terraform apply -target="module.networking" -target="module.front_door" -var="initial_create=true"```

(Need the networking explicitly otherwise we get an error creating the load balancer, there's some kind of dependency that terraform doesn't quite get)

This will create the certificates, load balancer, cloudfront distribution, and some networking and other things.

Potentially also do the secrets at this point (once they are pulled out of the application module) since they also have a manual step, so you can fill them out before the app itself is created and tries to read them.

### Get DNS Records set up

Ask DLUHC to set up DNS records required.

This will be;
* Validation for the cloudfront certificate
* Validation for the load balancer certificate
* CNAME for the cloudfront domain pointing at the cloudfront distribution
* CNAME for the load balancer domain pointing at the load balancer

### Run a full apply

Once these have been done, run a complete apply


### Set up the database

If not restoring the database from a backup, or migrating it from elsewhere, run the db:setup rake task (use the ad_hoc task definition to spin it up from the app image with a command override).