terraform {
  # “I’ve only run this on 1.11 or newer, so module reusability may be limited for now”
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # Root sets the ceiling
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Applied automatically to every taggable resource this config creates.
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
      Repository  = "aws-terraform-platform"
    }
  }
}
