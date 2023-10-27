# Performance testing

This is a set of very rough and ready performance tests, intended to check that the new infrastructure allows for sufficient concurrent users.

They are intended more as a probably-single-use smoke test than a complete cover-everything solution.

If developing on these, strongly recommend updating `test.yml` to have a single phase with much smaller numbers.

N.B. These numbers are probably much larger than actual usage. 

To run on AWS;

* May need to turn off WAF rate limiting temporarily (or it might be fine, haven't tried)
* Make sure the env is suitable set up (not going to email real people, have some suitable test users)
* Update users.csv to have a selection of users from different orgs, some of whom (the orgs at least) should have many logs already - this goes username,password,logIdentifier - logIdentifier should be something that that user could search for to see a particular log
* Open a shell logged into the relevant AWS env (actually does not need to be the same env but probably should be) - e.g. `aws-vault exec dluhc-production`
* Run the tests: `npx artillery run-fargate test.yml --region eu-west-1 --output report.json` (This will take some time, and annoyingly it looks like --quiet doesn't work with run-fargate (would recommend it when running from your machine))
* Exit the AWS shell
* `npx artillery report report.json` to see generate html report (nice graphs)

Todo (maybe):
* Be nice to have a script for sorting out users.csv
* Don't duplicate the site url
* Bulk upload
* Downloads?