terraform {
  backend "s3" {
    bucket = "terraform-nu2dp3915g"
    key    = "backend/state.tf"
    region = "eu-west-1"

    dynamodb_table = "terraform"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 3.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}
