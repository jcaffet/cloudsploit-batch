#!/bin/sh

TMP_ASSUME_ROLE_FILE=/tmp/assume-role.json

echo "Collecting credentials for ${ACCOUNT} for role ${CLOUDSPLOIT_ROLE_TO_ASSUME}"
aws sts assume-role --role-arn arn:aws:iam::${ACCOUNT}:role/${CLOUDSPLOIT_ROLE_TO_ASSUME} \
										--external-id ${CLOUDSPLOIT_ROLE_EXTERNALID} \
	                  --role-session-name ${CLOUDSPLOIT_ROLE_TO_ASSUME} \
										>${TMP_ASSUME_ROLE_FILE}

export AWS_SECRET_ACCESS_KEY=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SecretAccessKey`
if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then echo "AWS_SECRET_ACCESS_KEY not set !"; exit 1; fi

export AWS_ACCESS_KEY_ID=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.AccessKeyId`
if [ -z "${AWS_ACCESS_KEY_ID}" ]; then echo "AWS_ACCESS_KEY_ID not set !"; exit 1; fi

export AWS_SESSION_TOKEN=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SessionToken`
if [ -z "${AWS_SESSION_TOKEN}" ]; then echo "AWS_SESSION_TOKEN not set !"; exit 1; fi

now=`date +'%Y-%m-%d'`
report_file_prefix=${ACCOUNT}-${now}
echo "Generating CloudSploit PCI DSS compliance report ..."
node index.js --compliance=pci >${report_file_prefix}-pcidss.txt

echo "Generating CloudSploit CIS Benchmarks compliance report ..."
node index.js --compliance=cis >${report_file_prefix}-cis.txt

echo "Saving the report files in s3://${CLOUDSPLOIT_BUCKET}/reports/${ACCOUNT}"
unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID
unset AWS_SESSION_TOKEN
aws s3 cp . s3://${CLOUDSPLOIT_BUCKET}/reports/${ACCOUNT}/ --exclude="*" --include="${report_file_prefix}*" --recursive
