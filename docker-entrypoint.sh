#!/bin/sh

TMP_ASSUME_ROLE_FILE=/tmp/assume-role.json

echo "Collecting credentials for ${ACCOUNT} for role ${CLOUDSPLOIT_ROLE_TO_ASSUME}"
aws sts assume-role --role-arn arn:aws:iam::${ACCOUNT}:role/${CLOUDSPLOIT_ROLE_TO_ASSUME} \
	            --role-session-name ${CLOUDSPLOIT_ROLE_TO_ASSUME} >${TMP_ASSUME_ROLE_FILE}

export AWS_SECRET_ACCESS_KEY=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SecretAccessKey`
export AWS_ACCESS_KEY_ID=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.AccessKeyId`
export AWS_SESSION_TOKEN=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SessionToken`

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

