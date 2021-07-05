terraform {
  backend "s3" {
    bucket = "terraform-nu2dp3915g"
    key    = "iam/state.tf"
    region = "eu-west-1"

    dynamodb_table = "terraform"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}
