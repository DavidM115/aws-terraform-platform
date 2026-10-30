variable "project" {
  description = "Short project name, used as a prefix in resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,30}$", var.project))
    error_message = "project name must be 3-30 characters: lowercase letters, numbers, and hyphens only."
  }
}

variable "environment" {
  description = "The deployment environment (e.g., dev, prod)."
  type        = string

  validation {
    condition     = contains(["dev", "prod", "staging"], var.environment)
    error_message = "Environment name must be dev, prod, or staging."
  }

}

variable "vpc_id" {
  description = "The network module's VPC ID for the flow log."
  type        = string

  validation {
    condition     = startswith(var.vpc_id, "vpc-")
    error_message = "Invalid VPC ID, must start with 'vpc-'."
  }
}

variable "enable_force_destroy" {
  description = "Allows Terraform to delete a bucket that still holds objects ('dev' environment only)."
  type        = bool
  nullable    = false # Variable must have a value that is not null

  validation {
    condition     = var.environment == "dev" || !var.enable_force_destroy
    error_message = "force_destroy can only be enabled in the 'dev' environment."
  }
}

variable "log_retention_days" {
  description = "Days until log objects expire."
  type        = number
  nullable    = false # Variable must have a value that is not null

  validation {
    condition     = var.log_retention_days > 0
    error_message = "Retention value must be a positive number greater than 0."
  }
}

variable "noncurrent_object_retention_days" {
  description = "Days to keep noncurrent versions of backed-up objects."
  type        = number

  validation {
    condition     = var.noncurrent_object_retention_days == null ? true : var.noncurrent_object_retention_days > 0
    error_message = "Retention value must be a positive number greater than 0, or set to null to keep them forever,"
  }
}
