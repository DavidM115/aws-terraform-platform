variable "project" {
  description = "Short project name, used as a prefix in resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,30}$", var.project))
    error_message = "project name must be 3-30 characters: lowercase letters, numbers, and hyphens only."
  }
}

variable "environment" {
  description = "The deployment environment (e.g., dev, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "prod", "staging"], var.environment)
    error_message = "Environment name must be dev, prod, or staging."
  }
}


/*
Variables for 2nd option:

variable "bucket_name" {
  description = "The globally unique name of the S3 bucket"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable versioning for this bucket"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket"
  type        = map(string)
  default     = {}
}





*/