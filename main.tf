terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region_name
  profile = var.profile_name
}

locals {
  tags = {
    Environment = var.env_name
  }
}
