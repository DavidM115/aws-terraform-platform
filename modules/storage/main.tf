module "s3_bucket" {
  source      = "../s3-bucket"
  environment = var.environment
  project     = var.project

}


# S3 Logging VPC Flow Log
resource "aws_flow_log" "s3_flow_log" {
  log_destination      = module.s3_bucket.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id.id
}

resource "aws_s3_bucket" "VPC_s3_bucket" {
  bucket = "my-tf-test-bucket"

  force_destroy = true

  tags = {
    Name = "${var.project}-${var.environment}-VPC_s3_bucket"
  }
}








# Versioning lets you recover from a corrupted or accidentally overwritten state file.
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.VPC_s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}





/*
force_destroy true for dev only example:
variable "environment" {
  type    = string
  default = "dev"
}

variable "enable_force_destroy" {
  type    = bool
  default = false

  validation {
    condition     = var.environment == "dev" || !var.enable_high_availability
    error_message = "force_destroy can only be enabled in the 'dev' environment."
  }
}





*/