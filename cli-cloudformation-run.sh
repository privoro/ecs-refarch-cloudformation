#!/bin/bash
set -ex

# USE AWS CLI TO CREATE A STACK FROM CLOUDFORMATION

CF_STACK_NAME=$1
TEMPLATE_FILENAME=$2
# For now we need to assume to use some existing AWS resources to simplify stack creation for testing
SSH_KEYPAIR_ID=development-ssh-keypair-pem
SUBNET_ID=subnet-0b80bb6c
VPC_ID=vpc-837997e5

# just pick the first AZ of the region and work with that for now
# need jq installed on system path, but then we can parse out data we want easily, strip quotes w. sed
AVAILZONE=$(aws ec2 describe-subnets --filters "Name=subnet-id,Values=${SUBNET_ID}" | jq '.Subnets[0].AvailabilityZone' | sed -e 's/^"//' -e 's/"$//')

aws cloudformation create-stack --stack-name=${CF_STACK_NAME} \
--template-body file://${TEMPLATE_FILENAME} \
--parameters \
ParameterKey=KeyName,ParameterValue=${SSH_KEYPAIR_ID} \
ParameterKey=VPC,ParameterValue=${VPC_ID} \
ParameterKey=StackAZ,ParameterValue=${AVAILZONE} \
--capabilities CAPABILITY_NAMED_IAM

#--disable-rollback

echo "StackName=$1"
echo "next step..."
printf "./get-outputs.sh $CF_STACK_NAME && source <(./get-outputs.sh $CF_STACK_NAME)\n"
