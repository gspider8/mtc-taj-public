terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["/home/ubuntu/.aws/credentials"]
  # access to credentials to terraform granted by c9
}