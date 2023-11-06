# Performance testing

This is a set of very rough and ready performance tests, intended to check that the new infrastructure allows for sufficient concurrent users.

They are intended more as a probably-single-use smoke test than a complete cover-everything solution.

If developing on these, strongly recommend updating `test.yml` to have a single phase with much smaller numbers.

N.B. These numbers are probably much larger than actual usage. 

To run on AWS;

* May need to turn off WAF rate limiting temporarily (or it might be fine, haven't tried)
* Make sure the env is suitable set up (not going to email real people, have some suitable test users)
* Update users.csv to have a selection of users from different orgs, some of whom (the orgs at least) should have many logs already - see users.csv.template for what should be in there - logIdentifier should be something that that user could search for to see a particular log
* Ensure the performance testing infra has been created in the meta account
* Build and upload a docker image (built from the performance folder, without node-modules present) to the relevant repository (N.B. this will be in eu-west-1, because of artillery limitations)
* Trigger the performance testing task from either the AWS console or the CLI.
* Once it's complete, look in the s3 bucket for the report.
