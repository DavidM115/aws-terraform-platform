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

variable "vpc_id" {
  description = "The network module's VPC ID with the security group created in it"
  type        = string

  validation {
    condition     = startswith(var.vpc_id, "vpc-")
    error_message = "Invalid VPC ID, must start with 'vpc-'."
  }
}