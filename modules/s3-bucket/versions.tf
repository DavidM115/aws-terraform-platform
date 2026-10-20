terraform {
  # “I’ve only run this on 1.11 or newer, so module reusability may be limited for now”
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0" # Modules state the floor
    }
  }
}
