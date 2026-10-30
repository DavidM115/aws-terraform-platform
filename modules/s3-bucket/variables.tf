variable "environment" {
  description = "The deployment environment (e.g., dev, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "prod", "staging"], var.environment)
    error_message = "Environment name must be dev, prod, or staging."
  }
}

variable "bucket_name" {
  description = "The globally unique name of the S3 bucket."
  type        = string

  validation {
    condition = (

      # Rule 1: 3-63 characters, lowercase letters, numbers, dots, and hyphens. 
      # Must start and end with a letter or number.
      can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name)) &&

      # Rule 2: Cannot contain consecutive periods (..)
      !can(regex("\\.\\.", var.bucket_name)) &&

      # Rule 3: Cannot be formatted as an IP address
      !can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$", var.bucket_name)) &&

      # Rule 4: Cannot start with common forbidden prefixes
      !can(regex("^(xn--|sthree-|amzn-s3-demo-)", var.bucket_name)) &&

      # Rule 5: Cannot end with common forbidden suffixes or directory bucket markers
      !can(regex("(-s3alias|--ol-s3|\\.mrap|--x-s3|--table-s3)$", var.bucket_name))
    )

    error_message = "Bucket name must be 3-63 characters: lowercase letters, numbers, hyphens, dots, start/end with a letter or number, and adhere to AWS naming conventions."
  }
}

variable "versioning_enabled" {
  description = "Enable versioning for this bucket."
  type        = bool
  default     = true
}

# force_destroy true for dev only 
variable "enable_force_destroy" {
  description = "Allows the dev environment to destroy S3 buckets, empty or not."
  type        = bool
  default     = false

  validation {
    condition     = var.environment == "dev" || !var.enable_force_destroy
    error_message = "force_destroy can only be enabled in the 'dev' environment."
  }
}

variable "days_until_current_objects_expire" {
  description = "Days before current objects expire (null keeps them forever)."
  type        = number
  default     = null

  validation {
    condition     = var.days_until_current_objects_expire == null ? true : var.days_until_current_objects_expire > 0
    error_message = "Lifecycle value must be a positive number greater than 0, or left unset (null, which keeps them forever)."
  }
}

variable "days_until_old_versions_expire" {
  description = "Days before old versions expire (null keeps them forever)."
  type        = number
  default     = null

  validation {
    condition     = var.days_until_old_versions_expire == null ? true : var.days_until_old_versions_expire > 0
    error_message = "Lifecycle value must be a positive number greater than 0, or left unset (null, which keeps them forever)."
  }

  validation {
    condition     = var.versioning_enabled || var.days_until_old_versions_expire == null
    error_message = "Cannot set old-version expiry if versioning is off."
  }
}

variable "extra_policy_documents" {
  description = "Empty list for additional bucket policy documents in JSON format to merge."
  type        = list(string)
  default     = []
}
