#!/bin/bash
set -ex

echo "Region [$AWSRegion]"
echo "Cluster [$ECSClusterName]"
echo "Task Definition [$TaskDefinitionArn]"

TaskArns=$(aws ecs list-tasks --region $AWSRegion \
--cluster $ECSClusterName --query taskArns --output text)
echo "Task ARNs [$TaskArns]"

ContainerInstanceArns=$(aws ecs describe-tasks \
--region $AWSRegion --cluster $ECSClusterName \
--tasks $TaskArns \
--query 'tasks[?taskDefinitionArn==`'$TaskDefinitionArn'`]' \
--query 'tasks[].containerInstanceArn' --output text)
echo "Container Instance ARNs [$ContainerInstanceArns]"

echo "DRAINING Instances"
UpdateContainterState=$(aws ecs update-container-instances-state --region $AWSRegion \
--cluster $ECSClusterName --container-instances $ContainerInstanceArns \
--status "DRAINING" --output text)

set +x
echo "$UpdateContainterState"
echo "draining over, check the log though to make sure dude"


# NOTES
# query to test if persistence is working
# rate(prometheus_tsdb_head_chunks_created_total[1m])
# if i drain and come back on diff ec2, should still see stamp
# 18:05:41 val 7.38