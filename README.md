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

## Detailed Setup Steps.
**Step1: Create the module for VPC
* Create `main.tf` file and add the below code to it 
   # Creating VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
    Env  = var.env
    Type = var.type
  }
}

# Creating Internet Gateway and attach it to VPC
resource "aws_internet_gateway" "eks_internet_gateway" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
    Env  = var.env
    Type = var.type
  }
}

# Using data source to get all Avalablility Zones in region
data "aws_availability_zones" "available_zones" {}

# Creating Public Subnet AZ1
resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnet_az1_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet AZ1"
    Env  = var.env
    Type = var.type
  }
}

# Creating Public Subnet AZ2
resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnet_az2_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet AZ2"
    Env  = var.env
    Type = var.type
  }
}

# Creating Route Table and add Public Route
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_internet_gateway.id
  }

  tags = {
    Name = "Public Route Table"
    Env  = var.env
    Type = var.type
  }
}

# Associating Public Subnet in AZ1 to route table
resource "aws_route_table_association" "public_subnet_az1_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associating Public Subnet in AZ2 to route table
resource "aws_route_table_association" "public_subnet_az2_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_route_table.id
}