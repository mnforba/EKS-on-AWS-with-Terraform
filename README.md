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

    You have created s3 bucket that will act as the backend of the project.

    You have your environmental variables set up.

## Quick Setup
Clone the repository:

    git clone https://github.com/mnforba/EKS-on-AWS-with-Terraform.git

Change directory;

    cd EKS-on-AWS-with-Terraform

Update the `backend.tf` and update the s3 bucket and the region of your s3 bucket. Update the profile if you are not using the default profile. 

Update the `variables.tf` profile and region variables if you are not using the default profile or region used. 

If there is a role you want to add to be able to access the EKS cluster created, create the following environment variable in your working server. 

    TF_VAR_rolearn

If there is no role to add, disable adding role to the configmap by commenting out the following field in `modules/eks-cluster/main.tf`

    manage_aws_auth_configmap = true

Check your environmetal variables using `echo $AWS_ACCESS_KEY_ID` && `echo $AWS_SECRET_ACCESS_KEY`. If they're not set, you can set them temporarily:

    export AWS_ACCESS_KEY_ID="your-access-key-id"
    export AWS_SECRET_ACCESS_KEY="your-secret-access-key"

You can create a dynamodb table using the command

    aws dynamodb create-table \
         --table-name my-terraform-lock-table \
         --attribute-definitions AttributeName=LockID,AttributeType=S \
         --key-schema AttributeName=LockID,KeyType=HASH \
         --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
         --region us-west-2

Initialize the project to pull all the moduels used

    terraform init

Validate that the project is correctly setup. 

    terraform validate

Run the plan command to see all the resources that will be created

    terraform plan

When you ready, run the apply command to create the resources. 

    terraform apply


