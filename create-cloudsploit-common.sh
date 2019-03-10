#!/bin/bash

usage(){
    echo "Usage: $0 <profile> <environment>" 
    echo "profile : aws profile to use for deployment" 
}

if [ $# -eq 1 ]; then
   profile=$1
else
   usage;
   exit 1;
fi

echo "Creating stack"
aws --profile=${profile} cloudformation create-stack \
    --stack-name cloudsploit-common \
    --capabilities CAPABILITY_NAMED_IAM \
    --template-body file://cf-cloudsploit-common.yml \
    --parameters ParameterKey=TagBlock,ParameterValue=security \
                 ParameterKey=TagApp,ParameterValue=cloudsploit \
                 ParameterKey=TagOrg,ParameterValue=cloudaccelerationteam \
                 ParameterKey=CloudSploitEcrRepoName,ParameterValue=cloudaccelerationteam/cloudsploit

