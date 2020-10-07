terraform {
  backend "s3" {
    bucket = "apn-terraform-state-prod"
    key    = "rancher/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  required_version = ">= 0.13"
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "r53"
  region = "us-east-1"
}

module "global" {
  source = "../.global"
}

module "network_lookup" {
  source = "../../modules/core/network-lookup"
}