terraform {
  backend "s3" {
    bucket = "terraform-nu2dp3915g"
    key    = "budget/state.tf"
    region = "eu-west-1"

    dynamodb_table = "terraform"
  }
}

provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}
