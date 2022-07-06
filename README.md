# dmp-roadmap-cfn

AWS orchestration to run the [DMPRoadmap](https://github.com/DMPRoadmap/roadmap) open source codebase.

![DMPRoadmap AWS infrastructure](https://github.com/CDLUC3/dmp-roadmap-cfn/blob/main/dmproadmap.png?raw=true)
__(see below for a glossary of acroyms referenced in the diagram)__

## Repository structure

The `application/` directory contains the DMPRoadmap codebase as a git submodule, the Dockerfile and various configuration files to build the Docker image.

The `cf-templates/` directory contains the Sceptre Cloud Formation templates.

Your will need to run `git submodule init` and then `git submodule update` to pull in the DMPRoadmap codebase. Once this is complete, you can move into the `application/roadmap` directory and interact with the DMPRoadmap code normally (e.g. fetch/pull the appropriate branch or tag).

The Cloud Formation templates will build out the entire stack of AWS resources to host the open source codebase. **Note that running these templates will create AWS resources that you will be billed for!**

## Prerequisites

The follow must be setup before you can build out the AWS infrastructure:
- You must of couse have an AWS account
- A VPC and Subnets already defined in AWS (update these values in the `config` files to match the ones you use)
- A Route53 hosted zone (update this value in the `config` files to match your zone)
- Define the following SSM parameters:
  - /uc3/dmp/dev/hosted_zone_name  <-- used by the Route53 resources (e.g. example.edu)
  - /uc3/dmp/roadmap/dev/db_dba_username  <-- used by the application to connect to RDS
  - /uc3/dmp/roadmap/dev/db_dba_password  <-- used by the application to connect to RDS
- If you have an existing RDS snapshot that you would like to use, you can specify the ARN of the snapshot in the `DBSnapshot` parameter in the `config` files. You can comment out this parameter in the files to have the Docker deploy process build a new DB and seed it for you from the `application/roadmap/db/seeds.rb` script.

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

## Before you delete the AWS cloud formation stack

You should create a snapshot of the RDS database before you delete the stack. Once the snapshot has been created, you should replace the `DBSnapshot` entries in the `config` files with the ARN of the new snapshot. This will ensure that tge next time you create the stack, the database will be restored.

## Troubleshooting

- The Docker image sends its logs to the `uc3-dmp-roadmap-dev-ecs` CloudWatch LogGroup. You can go to this log group in the AWS console to investigate application errors.

- HTTP 502 and 503 errors indicate that ECS was either unable to deploy the application (or is in the process of doing so). Check the CloudWatch logs referenced above for more information.

## Glossary
- **ALB** Application Load Balancer
- **CloudWatch** AWS logging service, we send logs here and it provides tooling for metrics, setting alarms, etc.
- **ECR** Elastic Container Repository, an AWS version of DockerHub
- **ECS** Elastic Container Service (we use Fargate), an AWS managed auto-scaling system that deploys and maintans instances of the application
- **IAM** Identity and Access Management, roles that determine what a resource can do
- **RDS** Relational Database Service, an AWS managed database like mySQL or Postgres
- **Route53** AWS Domain Name System
- **SecurityGroup** AWS Elastic Compute Cloud (EC2) security groups that manage which resources can talk to one another and over which protocols/ports
- **SES** Simple Email Service
- **SSM** Systems Manager, a key-value store used to supply the ECS containers with information (e.g. DB credentials)
- **WAF** Web Application Firewall