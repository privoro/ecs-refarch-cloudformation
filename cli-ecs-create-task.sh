#!/bin/bash
set -ex

#if AUTOPROVISION is not set true,  need a rexray compatible volume resource
# aws create-volume --size 1 --volume-type gp2 \
# --availability-zone $AvailabilityZone \
# --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=rexray-vol}]'

cat > prom-task-def.json <<EOF 
{
  "containerDefinitions": [
      {
          "logConfiguration": {
              "logDriver": "awslogs",
              "options": {
                  "awslogs-group": "${CWLogGroupName}",
                  "awslogs-region": "${AWSRegion}",
                  "awslogs-stream-prefix": "ecs"
              }
          },
          "portMappings": [
              {
                  "containerPort": 9090,
                  "protocol": "tcp"
              }
          ],
          "environment": [
              {
                  "name": "MYSQL_ROOT_PASSWORD",
                  "value": "privoro"
              }
          ],
          "mountPoints": [
              {
                  "containerPath": "/var/lib/prometheus",
                  "sourceVolume": "rexray-vol"
              }
          ],
          "image": "492058901556.dkr.ecr.us-west-2.amazonaws.com/prometheus:latest",
          "essential": true,
          "name": "prometheus-container"
      }
  ],
  "placementConstraints": [
      {
          "type": "memberOf",
          "expression": "attribute:ecs.availability-zone==${AvailabilityZone}"
      }
  ],
  "memory": "512",
  "family": "prometheus",
  "networkMode": "awsvpc",
  "requiresCompatibilities": [
      "EC2"
  ],
  "cpu": "512",
  "volumes": [
      {
          "name": "rexray-vol",
          "dockerVolumeConfiguration": {
              "autoprovision": true,
              "scope": "shared",
              "driver": "rexray/ebs",
              "driverOpts": {
                  "volumetype": "gp2",
                  "size": "5"
              }
          }
      }
  ]
}
EOF
sync && sleep 1

#cat prom-task-def.json

#exit 0

TaskDefinitionArn=$(aws ecs register-task-definition \
--cli-input-json 'file://prom-task-def.json' \
| jq -r .taskDefinition.taskDefinitionArn)

set +ex
echo "task creation done"
echo "ARN: ${TaskDefinitionArn}"
export TaskDefinitionArn=${TaskDefinitionArn}

# temp file - annoying in search, git etc. so remove
rm -f prom-task-def.json