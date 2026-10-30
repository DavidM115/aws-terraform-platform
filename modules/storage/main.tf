data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  log_bucket_name     = "${var.project}-${var.environment}-logs-${data.aws_caller_identity.current.account_id}"
  backups_bucket_name = "${var.project}-${var.environment}-backups-${data.aws_caller_identity.current.account_id}"
}

# Log Bucket
module "vpc_log_bucket" {
  source                            = "../s3-bucket"
  environment                       = var.environment
  bucket_name                       = local.log_bucket_name
  versioning_enabled                = false
  enable_force_destroy              = var.enable_force_destroy
  days_until_current_objects_expire = var.log_retention_days
  extra_policy_documents            = [data.aws_iam_policy_document.flow_log_delivery.json]
}

# Backup Bucket
module "backups_bucket" {
  source                         = "../s3-bucket"
  environment                    = var.environment
  bucket_name                    = local.backups_bucket_name
  versioning_enabled             = true
  enable_force_destroy           = var.enable_force_destroy
  days_until_old_versions_expire = var.noncurrent_object_retention_days
}

# S3 Logging VPC Flow Log
resource "aws_flow_log" "s3_flow_log" {
  log_destination      = "arn:aws:s3:::${local.log_bucket_name}"
  log_destination_type = "s3"
  traffic_type         = "ALL" #ALL is most useful, and REJECT only is cheaper.
  vpc_id               = var.vpc_id

  depends_on = [module.vpc_log_bucket]
}

# Bucket policy to grant permission for logging
data "aws_iam_policy_document" "flow_log_delivery" {
  statement {
    sid       = "AWSLogDeliveryWrite"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.log_bucket_name}/*"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"]
    }

  }
  statement {
    sid       = "AWSLogDeliveryAclCheck"
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${local.log_bucket_name}"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}
