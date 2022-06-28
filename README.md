# aws-dmp-roadmap
AWS orchestration to run the DMPRoadmap open source codebase

## Creating the stack

### Build out the DB and ECR repository

The DMPRoadmap system requires access to a database and the Fargate serverless architecture and CodePipeline require that we store the application's docker image in a repository.

Build the persistent resources (ECR, S3 and RDS) for the application by running: `sceptre create dev/data.yaml`

### Add a base image to the ECR

The CodePipeline and Fargate setup require that the ECR contains an initial Docker image for the application. To create a base image:


