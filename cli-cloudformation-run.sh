#!/bin/bash


aws cloudformation create-stack --stack-name=$1 \
--template-body file://$2 \
--parameters ParameterKey=KeyName,ParameterValue=development-ssh-keypair-pem \
--capabilities CAPABILITY_NAMED_IAM

#--disable-rollback