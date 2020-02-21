#!/bin/bash
set -ex

TaskDefinitionArn=$1

cat > prom-svc-def.json << EOF 
{
    "cluster": "${ECSClusterName}",
    "serviceName": "prometheus-svc",
    "taskDefinition": "${TaskDefinitionArn}",
    "loadBalancers": [
        {
            "targetGroupArn": "${PrometheusTargetGroupArn}",
            "containerName": "prometheus-container",
            "containerPort": 9090
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


# temp file - annoying in search, git etc. so remove
rm -f prom-svc-def.json

echo "service created"
echo $SvcDefinitionArn

printf "service will be reachable through elb at:\n${NLBFullyQualifiedName}:9090\n"
printf "container won't be ready for at least 4-5 mins... now waiting and polling server"


