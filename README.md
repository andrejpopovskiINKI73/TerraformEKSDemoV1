# Automated Deployment Pipeline with Jenkins, Terraform, Kubernetes, and AWS
This repository contains a Jenkinsfile that automates the deployment of an application stack to Kubernetes (k8s) using Terraform for infrastructure provisioning and Docker for containerization. AWS resources are also utilized for this deployment.

## Prerequisites
Before you can use the provided Jenkinsfile to deploy your application stack, make sure you have the following prerequisites in place:

### Jenkins Setup:

1. Install and configure Jenkins on your target system.

- Jenkins Plugins:
Install the necessary plugins in Jenkins:
Pipeline plugin
Credentials Binding plugin
PowerShell plugin

- Jenkins Credentials:
Create the following credentials in Jenkins:
dockerhubpwd: Docker Hub password used for logging in and pushing Docker images.
aws_access_key: AWS access key for authentication.
aws_secret_key: AWS secret key for authentication.

- Terraform:
Install Terraform version Terraform-1 using the Jenkins tool configuration. Ensure the tool name matches the configuration in Jenkins.

Git:
- Ensure Git is installed and configured on the Jenkins agent.

- Kubectl:
Install kubectl on the Jenkins agent.

- Node.js and npm:
Install Node.js and npm on the Jenkins agent for building the frontend application.

- Java and Maven:
Install Java and Maven on the Jenkins agent for building the web application.

- Python and pip:
Install Python and pip on the Jenkins agent for the logic application.

- Docker:
Install Docker on the Jenkins agent for building and pushing Docker images.

- GitHub Repository:
The Jenkinsfile is designed to work with a specific GitHub repository URL: https://github.com/andrejpopovskiINKI73/TerraformEKSDemoV1.git. Make sure this repository is accessible and contains the necessary Terraform and Kubernetes resources.

- Pipeline Parameters:
Configure the Jenkins pipeline to accept parameters as specified in the Jenkinsfile:
Actions: Choices are plan, apply, destroy, skip.
BuildDockerImages: Boolean indicating whether to build new Docker images.
AWS Configuration
Ensure you have the following AWS configuration in your pipeline:

- AWS IAM User:
Create an IAM user with necessary permissions for Terraform to manage AWS resources.

- AWS Access Credentials:
Configure the aws_access_key and aws_secret_key credentials in Jenkins for the IAM user.

## Usage

- Make sure all prerequisites and AWS configuration are met on your Jenkins agent.

- Run the pipeline and select appropriate parameters:
Actions: Choose from plan, apply, destroy, or skip.
BuildDockerImages: Set to true if you want to build new Docker images.
The pipeline will automate the deployment process based on your selections, utilizing AWS resources.

## Additional Notes

Adjust paths, URLs, and other configurations in the Jenkinsfile to match your environment.

The pipeline stages automate the deployment of different components (web app, frontend, logic) to Kubernetes.

The pipeline includes error handling and email notifications for success and failure.

Remember to replace andrej.popovski.iw@gmail.com with appropriate email addresses for notifications.

By following these steps and prerequisites, you can use the provided Jenkinsfile to automate the deployment of your application stack to Kubernetes using Terraform, Docker, and AWS resources.