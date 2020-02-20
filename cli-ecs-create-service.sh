#!/bin/bash
set -ex

TaskDefinitionArn=$1

cat > prom-svc-def.json << EOF 
{
    "cluster": "${ECSClusterName}",
    "serviceName": "mysql-svc",
    "taskDefinition": "${TaskDefinitionArn}",
    "loadBalancers": [
        {
            "targetGroupArn": "${MySQLTargetGroupArn}",
            "containerName": "mysql",
            "containerPort": 3306
        }
    ],
    "desiredCount": 1,
    "launchType": "EC2",
    "healthCheckGracePeriodSeconds": 60, 
    "deploymentConfiguration": {
        "maximumPercent": 100,
        "minimumHealthyPercent": 0
    },
    "networkConfiguration": {
        "awsvpcConfiguration": {
            "subnets": [
                "${SubnetId}"
            ],
            "securityGroups": [
                "${SecurityGroupId}"
            ],
            "assignPublicIp": "DISABLED"
        }
    }
}
EOF

sync && sleep 1

SvcDefinitionArn=$(aws ecs create-service \
--cli-input-json file://prom-svc-def.json \
| jq -r .service.serviceArn)

echo "service created"
echo $SvcDefinitionArn

printf "try to access service thru elb at:\n${NLBFullyQualifiedName}\n"