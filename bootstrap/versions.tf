terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Applied automatically to every taggable resource this config creates.
  default_tags {
    tags = {
      Project     = var.project
      Environment = "bootstrap"
      ManagedBy   = "terraform"
      Repository  = "aws-terraform-platform"
    }
  }
}
