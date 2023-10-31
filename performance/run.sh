#!/bin/sh

run_timestamp=`date "+Y%m%d-%H%M%S"`

npx artillery run-fargate --region eu-west-1 --output report.json

npx artillery report report.json

aws s3 cp report.json.html $OUTPUT_BUCKET/$run_timestamp