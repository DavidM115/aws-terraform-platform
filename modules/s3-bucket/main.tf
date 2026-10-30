# Create S3 bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.bucket_name
  force_destroy = var.enable_force_destroy

  tags = {
    Name = var.bucket_name
  }
}

# Modern default that turns off ACLs
resource "aws_s3_bucket_ownership_controls" "bucket_owner" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Block all public access (Security Best Practice)
resource "aws_s3_bucket_public_access_block" "block_s3_access" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# Bucket policy to enforce TLS-only (HTTPS) access on the S3 bucket
data "aws_iam_policy_document" "tls_only" {
  statement {
    sid     = "EnforceTLS"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.s3_bucket.arn,
      "${aws_s3_bucket.s3_bucket.arn}/*"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

# Merges internal data source JSON and variable list into a single JSON policy
data "aws_iam_policy_document" "combined_docs" {
  source_policy_documents = concat(
    [data.aws_iam_policy_document.tls_only.json],
    var.extra_policy_documents
  )
}

# Attach combined bucket policy document to S3 Bucket
resource "aws_s3_bucket_policy" "combined_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.combined_docs.json

  # Bucket policy and public access block can't be modified at the same time.
  depends_on = [aws_s3_bucket_public_access_block.block_s3_access]
}

# Enable/Disable versioning dynamically
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}

# SSE-S3 keeps this free. Upgrade to a KMS key later if you want key-level audit/control.
resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt_s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle Rule for days until new & old objects expire
resource "aws_s3_bucket_lifecycle_configuration" "bucket_config" {
  bucket     = aws_s3_bucket.s3_bucket.id
  depends_on = [aws_s3_bucket_versioning.versioning]

  # Rule 1: expire current objects
  dynamic "rule" {
    for_each = var.days_until_current_objects_expire != null ? [1] : []
    content {
      id     = "expire-current-objects"
      status = "Enabled"
      filter {}
      expiration {
        days = var.days_until_current_objects_expire
      }
    }
  }

  # Rule 2: expire old versions
  dynamic "rule" {
    for_each = var.days_until_old_versions_expire != null ? [1] : []
    content {
      id     = "expire-noncurrent-versions"
      status = "Enabled"
      filter {}
      noncurrent_version_expiration {
        noncurrent_days = var.days_until_old_versions_expire
      }
    }
  }

  # Rule 3: S3 needs at least one rule per configuration, and abandoned multipart uploads cost money.
  rule {
    id     = "delete-incomplete-uploads-rule"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
