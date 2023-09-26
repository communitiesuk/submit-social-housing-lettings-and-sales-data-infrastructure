#!/bin/sh

echo 'Logging into Gov PaaS'

if cf login -a api.london.cloud.service.gov.uk -u ${CF_USERNAME} -p ${CF_PASSWORD} -s ${CF_SPACE}; then
  echo 'Logged into Gov PaaS successfully'
else
  echo 'ERROR could not log into Gov Paas'
  exit 1
fi

echo "Setting up conduit into Gov PaaS DB and making dump file"

if cf conduit ${CF_SERVICE} -- pg_dump -v -j 2 --file dumpfile --no-acl --encoding utf8 --clean --no-owner --if-exists -Fc; then
  echo 'Dump file of PaaS DB created successfully'
else
  echo 'ERROR trying to conduit into the PaaS DB or creating the dump file'
  exit 1
fi

while [ ! -e  "$dumpfile"]; do
  echo "Checking dump file exists"
  sleep 1
done

while fuser dumpfile; do
    echo "Dump file is still being written to. Waiting for write operations to finish"
    sleep 1
done

echo 'Dump file ready for pg restore'
echo 'Starting pg restore of AWS DB'

if pg_restore -v -d ${DATABASE_URL} -j 4 --no-acl --clean --no-owner --if-exists -Fc dumpfile; then
  echo 'Ran pg restore on AWS DB successfully'
  exit 0
else
  echo 'ERROR running pg restore on AWS DB. Check if the errors reported are important or harmless as the restore may still have completed ok'
  exit 1
fi
