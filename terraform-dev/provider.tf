// Insert Access Tokens here
locals {
  AWS_ACCESS_KEY_ID     = ""
  AWS_SECRET_ACCESS_KEY = ""
  AWS_DEFAULT_REGION    = ""
}

terraform {

  backend "local" {
    path = "./terraform-dev"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }
  }
}


provider "aws" {
  region     = local.AWS_DEFAULT_REGION
  access_key = local.AWS_ACCESS_KEY_ID
  secret_key = local.AWS_SECRET_ACCESS_KEY
}