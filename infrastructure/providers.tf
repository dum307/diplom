terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = merge(var.tags, { Environment = "Dev" })
  }
}