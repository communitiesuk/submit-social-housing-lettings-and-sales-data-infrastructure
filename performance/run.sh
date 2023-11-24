#!/bin/sh

npx artillery run-fargate test.yml --region eu-west-1 --output report.json

npx artillery report report.json

npm run upload