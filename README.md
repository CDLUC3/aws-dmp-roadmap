# dmp-roadmap-cfn

AWS orchestration to run the [DMPRoadmap](https://github.com/DMPRoadmap/roadmap) open source codebase.

![DMPRoadmap AWS infrastructure](https://github.com/CDLUC3/dmp-roadmap-cfn/blob/main/dmproadmap.png?raw=true)

## Repository structure

The `application/` directory contains the DMPRoadmap codebase as a git submodule, the Dockerfile and various configuration files to build the Docker image.

The `cf-templates/` directory contains the Sceptre Cloud Formation templates.

Your will need to run `git submodule init` and then `git submodule update` to pull in the DMPRoadmap codebase. Once this is complete, you can move into the `application/roadmap` directory and interact with the DMPRoadmap code normally (e.g. fetch/pull the appropriate branch or tag).

The Cloud Formation templates will build out the entire stack of AWS resources to host the open source codebase. **Note that running these templates will create AWS resources that you will be billed for!**

## Build out the RDS database and ECR repository

An Relational Database Service (RDS) database is required in order for the Fargate Elastic Container Service (ECS) cluster to deploy the application. Fargate also expects an initial Docker image to be present in the Elastic Container Repository (ECR).

Build the ECR and RDS resources by running: `sceptre create dev/data.yaml`

Note: You can continue with the next step as soon as you see `ECRRepository AWS::ECR::Repository CREATE_COMPLETE` in the output.

The RDS resource can take over 10 minutes to complete.

## Add a base image to the ECR

You will need to build the Docker image and push it to the newly ccreated ECR repository. To do that, you should:

- Login to the AWS console and go to 'Amazon Elastic Container Registry (ECR)' page
- Click on 'repositories' on the left sidebar and then click on the 'uc3-dmp-roadmap-dev-ecr' repository
- Click the 'View push commands' button
- Follow the instructions to build the docker image and push it to the ECR (perform these actions within the `.application/` directory)
- The final 'push' step can take in excess of 10 minutes. Once it completes, return to the console and ensure that the repository now contains your image.

Note: You can use normal git commands to checkout a different branch/tag if necessary here before running `docker build`.

## Build the Route53 RecordSet, SSL cert, WAF and ALB resources

The container instances sit behind an Application Load Balancer (ALB) which is protected by a Web Application Firewall (WAF) and SSL certificate.

Build these resources by running: `sceptre create dev/frontend.yaml`

## Build the IAM Roles, Security Groups and ECS resources

The DMPRoadmap system uses Fargate - Elastic Container Service (ECS) to manage the auto-scaling resources that host the DMPRoadmap application.

Build these resources by running: `sceptre create dev/application.yaml`

Note: It can take several minutes for the ECS task to complete and for Fargate to deploy your initial Docker image. You can check either go to the ECS page in  the AWS console and wait until you see that the task is `Running` or you can go to the CloudWatch page and the `uc3-dmp-roadmap-dev-ecs` LogGroup and wait for it to start showing some log streams.

## Verify that the application is running and accessible

- Login to the AWS console and go to CloudFormation.
- Click on the `uc3-dmp-roadmap-dev-application` stack and go to the 'Outputs' tab
- Visit the URL defined in the 'DomainName' attribute

## Troubleshooting

- The Docker image sends its logs to the `uc3-dmp-roadmap-dev-ecs` CloudWatch LogGroup. You can go to this log group in the AWS console to investigate application errors.

- HTTP 502 and 503 errors indicate that ECS was either unable to deploy the application (or is in the process of doing so). Check the CloudWatch logs referenced above for more information.
