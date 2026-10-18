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

variable "private_subnet_id" {
  description = "Private Subnet ID, since the instance gets no public IP."
  type        = string

  validation {
    condition     = startswith(var.private_subnet_id, "subnet-")
    error_message = "Invalid Private Subnet ID, must start with 'subnet-'."
  }
}

variable "instance_type" {
  description = "EC2 instance type. Must be an x86_64 family, because the AMI path is x86_64."
  type        = string

  validation {
    condition     = can(regex("^(t3|t3a)\\.", var.instance_type))
    error_message = "instance_type must be an x86_64 family (t3 or t3a), because the AMI is x86_64 only."
  }
}