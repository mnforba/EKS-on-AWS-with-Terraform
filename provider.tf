# configure aws provider
provider "aws" {
  region  = var.region
  profile = "mnforba"
}

# configure backend
terraform {
  backend "s3" {
    bucket         = "mnforba-terraform"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    profile        = "mnforba"
    dynamodb_table = "terraform-state-lock-dynamodb"
  }
}
