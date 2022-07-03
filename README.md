# aws-dmp-roadmap
AWS orchestration to run the DMPRoadmap open source codebase

## Creating the stack

These Cloud Formation templates will build out the entire stack of AWS resources to host the [DMPRoadmap](https://github.com/DMPRoadmap/roadmap) open source codebase.

### Build out the DB and ECR repository

The DMPRoadmap system requires access to a database and the Fargate serverless architecture and CodePipeline require that we store the application's docker image in a repository.

Build the persistent resources (ECR, S3 and RDS) for the application by running: `sceptre create dev/data.yaml`

Note: You can continue with the next step as soon as you see `ECRRepository AWS::ECR::Repository CREATE_COMPLETE` in the output.

The RDS can take in over 10 minutes to complete.

### Add a base image to the ECR

The CodePipeline and Fargate setup require that the ECR contains an initial Docker image for the application. To create a base image:

- Login to the AWS console and go to 'Amazon Elastic Container Registry (ECR)' page
- Click on 'repositories' on the left sidebar and then click on the 'uc3-dmp-roadmap-dev-ecr' repository
- Click the 'View push commands' button
- Follow the instructions to build the docker image and push it to the ECR (perform these actions within the `.application/` directory)
- The final 'push' step can take in excess of 10 minutes. Once it completes, return to the console and ensure that the repository now contains your image.

Note: You can use normal git commands to checkout a different branch/tag if necessary here before running `docker build`.

### Build out Route53, ACL and ALB resources

The container instances sit behind an Application Load Balancer (ALB) which is protected by a Web Application Firewall (WAF) and SSL certificate.

Build these resources by running: `sceptre create dev/application.yaml`

### Build out the Security Groups and ECS resources

The DMPRoadmap system uses Fargate - Elastic Container Service (ECS) to manage the auto-scaling resources that host the DMPRoadmap application.

Build these resources by running: `sceptre create dev/frontend.yaml`

### Verify that the application is running and accessible

- Login to the AWS console and go to CloudFormation.
- Click on the `uc3-dmp-roadmap-dev-application` stack and go to the 'Outputs' tab
- Visit the URL defined in the 'DomainName' attribute
