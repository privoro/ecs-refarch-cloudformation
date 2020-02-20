# prometheus-ecs-cloudformation

Files for bringing up prometheus instance in ECS using cloudformation
`prometheus-cf.yml` is the main template
to run the template in CF, use:
 `cli-cloudformation-run.sh <stack_name> <template_file>`


`templates` contains reference templates for now
`prometheus-config/` contains a configuration for prometheus instance 


# steps to produce ECS env

- CREATE STACK
  - run the cloudformation template as shown in `./dev.sh` . this is just a demonstration of how to use the stack creation
  - after a successful stack creation do this
    - `./get-outputs.sh your_stack_name && source <(./get-outputs.sh your_stack_name)`
    - substitute the name of the stack you created. this sets up environment variables which let you easily create ecs tasks etc with templates and aws cli
    - you should see your environment has been added the following exports

  ```
  export MySQLTargetGroupArn=arn:aws:elasticloadbalancing:us-west-2:492058901556:targetgroup/prom-MySQL-50D536PLVTMF/0c772f2ceda2b302
  
  export NLBName=prom-Netwo-RO2P5C0DHTAV
  
  export ECSClusterName=prom-test-Wed-02-19-1243-rexray-demo
  
  export SecurityGroupId=sg-03dd95faf1748109f
  
  export NLBFullyQualifiedName=prom-Netwo-RO2P5C0DHTAV-b8497dd510d8e9af.elb.us-west-2.amazonaws.com
  
  export AWSRegion=us-west-2
  
  export AvailabilityZone=us-west-2a
  
  export CWLogGroupName=prom-test-Wed-02-19-1243-CWLogsGroup-1AK8E3A6KULPU
  
  export SubnetId=subnet-0b80bb6c
  ```

- CREATE TASK DEFINITION
  - with stack created we have a cluster and all associated parts, we need a task to run our container executable
  - create with `cli-ecs-create-task.sh`

- CREATE SERVICE
  - service will take task definition from environment and run it
  - create with `cli-ecs-create-service.sh`

- TEST SERVICE VIA ELB DNS HOSTNAME
  - The template in question incorporates an ELB as a resource. This gives a public IP by which container resources can be accessed from public internet. To find the public DNS:

  - Look at Cloudformation stack output in AWS web console - find ID given in Outputs > NLB Name.

  - Find this ID in EC2 console > left side, Load Balancers > find the NLB name in center list, click the list item.

  - Now you can see the public DNS in the summary below. This is the external interface to your container (for testing your web service/resource, usually). Example:

    - prom-Netwo-RO2P5C0DHTAV-b8497dd510d8e9af.elb.us-west-2.amazonaws.com

- TEST DRAINING SERVICE WITH PERSISTENT STORAGE
  - draining simulates the container being moved to another cluster ec2 container host
  - important to demonstrate persistent data being stored via rexray ebs volume mount
  - use script: `drain-instance.sh` . 
  - verify statuses in ECS console > Clusters > ECS Instances