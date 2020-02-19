#!/bin/bash
set -ex

aws cloudformation create-stack --stack-name=$1 \
--template-body file://$2 \
--parameters \
ParameterKey=KeyName,ParameterValue=development-ssh-keypair-pem \
ParameterKey=VPC,ParameterValue=vpc-837997e5 \
--capabilities CAPABILITY_NAMED_IAM

#--disable-rollback