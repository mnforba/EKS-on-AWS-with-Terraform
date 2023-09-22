# Creating EKS Cluster on AWS using Terraform Modules

Amazon Elastic Kubernetes Service (Amazon EKS) is a managed Kubernetes service provided by AWS. Through AWS EKS we can run Kubernetes without installing and operating a Kubernetes control plane or worker nodes. AWS EKS helps you provide highly available and secure clusters and automates key tasks such as patching, node provisioning, and updates.

![AWSEKS](https://github.com/mnforba/EKS-on-AWS-with-Terraform/assets/88167119/be3e9910-4c8f-4b2f-b5a4-4753eeea3821)

### Prerequisite
Before we proceed and provision EKS Cluster using terraform, there are a few commands or tools you need to have.

    1. AWS Account
   
    2. Basic understanding of AWS, Terraform and Kubernetes

    3. Github Account to store the code
### Assumptions
The following details makes the following assumptions.

    You have aws cli configured  - aws configure
    You have your environmental variables set: 
    Check your environmetal variables using: `echo $AWS_ACCESS_KEY_ID` & `echo $AWS_SECRET_ACCESS_KEY`

    You have created s3 bucket that will act as the backend of the project. 
