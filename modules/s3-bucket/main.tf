data "aws_caller_identity" "current" {}

# Create S3 bucket for logging 
resource "aws_s3_bucket" "logging" {
  bucket = "access-logging-bucket"

  tags = {
    Name = "${var.project}-${var.environment}-logging"
  }
}

data "aws_iam_policy_document" "logging_bucket_policy" {
  statement {
    principals {
      identifiers = ["logging.s3.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logging.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "logging" {
  bucket = aws_s3_bucket.logging.bucket
  policy = data.aws_iam_policy_document.logging_bucket_policy.json
}

/* Another Option

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

# Block all public access (Security Best Practice)
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Turn on default AES256 encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable/Disable versioning dynamically
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}





*/


/*
Terraform's S3 module:

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.0"

  bucket = "my-unique-small-bucket-name"
  
  # Basic security & settings
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
  
  versioning = {
    enabled = true
  }

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}


*/