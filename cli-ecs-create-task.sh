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
                  "containerPort": 3306,
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
                  "containerPath": "/var/lib/mysql",
                  "sourceVolume": "rexray-vol"
              }
          ],
          "image": "mysql",
          "essential": true,
          "name": "mysql"
      }
  ],
  "placementConstraints": [
      {
          "type": "memberOf",
          "expression": "attribute:ecs.availability-zone==${AvailabilityZone}"
      }
  ],
  "memory": "512",
  "family": "mysql",
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

echo "task creation done"
echo "ARN: ${TaskDefinitionArn}"
export TaskDefinitionArn=${TaskDefinitionArn}