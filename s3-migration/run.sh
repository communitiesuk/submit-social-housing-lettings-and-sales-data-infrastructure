#!/bin/sh

aws configure set region eu-west-2 --profile paas
aws configure set aws_access_key_id ${PAAS_ACCESS_KEY_ID} --profile paas
aws configure set aws_secret_access_key ${PAAS_SECRET_ACCESS_KEY} --profile paas

aws s3 sync ${PAAS_BUCKET} bucket/ --profile paas

aws s3 sync bucket/ ${NEW_BUCKET}