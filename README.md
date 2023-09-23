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
Clone the repository [mnforba](https://github.com/mnforba/EKS-on-AWS-with-Terraform.git):

    git clone https://github.com/mnforba/EKS-on-AWS-with-Terraform.git

Change directory;

    cd EKS-on-AWS-with-Terraform

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
## Step 1: Create thge module for VPC
* Create `main.tf` file and add the code from code base.
```
# Creating VPC
module "vpc" {
  source       = "./modules/VPC"
  project_name = var.project_name
  env          = var.env
  type         = var.type
}

# Creating security group
module "security_groups" {
  source       = "./modules/Security-groups"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  ssh_access   = var.ssh_access
  http_access  = var.http_access
  env          = var.env
  type         = var.type
}

# Creating key pair
module "key_pair" {
  source   = "./modules/Key-Pair"
  key_name = var.key_name
}

# Creating IAM resources
module "iam" {
  source = "./modules/IAM"
}

# Creating EKS Cluster
module "eks" {
  source                = "./modules/EKS"
  master_arn            = module.iam.master_arn
  worker_arn            = module.iam.worker_arn
  public_subnet_az1_id  = module.vpc.public_subnet_az1_id
  public_subnet_az2_id  = module.vpc.public_subnet_az2_id
  env                   = var.env
  type                  = var.type
  key_name              = var.key_name
  eks_security_group_id = module.security_groups.eks_security_group_id
  instance_size         = var.instance_size
  project_name          = var.project_name
}
```
Initialize the project to pull all the moduels used

    terraform init

Validate that the project is correctly setup. 

    terraform validate

Run the plan command to see all the resources that will be created

    terraform plan

When you ready, run the apply command to create the resources. 

    terraform apply

When you ready, run the destroy command to destroy the resources. 

    terraform destroy

### Launch kubectl Server
[Configure kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)

* In the curl command, I am using Kubernetes `1.24.0`. You can use any latest
```
curl -O https://s3.us-east-1.amazonaws.com/amazon-eks/1.24.0/2023-06-01/bin/linux/amd64/kubectl
```
```
openssl sha1 -sha256 kubectl
```
```
chmod +x ./kubectl
```
```
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
```
```
kubectl version --short --client
```
    
* In the below command, replace the name with your EKS cluster and AWS region where the cluster is located. 
```
aws eks update-kubeconfig - name <your-cluster-name> - region <your-region>
```
```
kubectl get nodes
```

       