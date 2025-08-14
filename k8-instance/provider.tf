terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }
  }

  backend "s3" {
    bucket       = "vs-terraform-practice"
    key          = "vs-terraform-practice/k8-instance"
    region       = "us-east-1"
    encrypt      = true 
  }
}

provider "aws" {
  region = "us-east-1"
}