variable "aws_region" {
  description = "AWS region for the state bucket."
  type        = string
  default     = "us-west-2"
}

variable "project" {
  description = "Short project name, used as a prefix in resource names."
  type        = string
  default     = "aws-tf-platform"

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

variable "single_nat_gateway" {
  description = "true: one shared NAT gateway (cheaper, but one AZ outage cuts off the private subnets). false: one NAT gateway per AZ (more resilient, costs more)."
  type        = bool
}

variable "instance_type" {
  description = "EC2 instance type. Must be an x86_64 family, because the AMI path is x86_64."
  type        = string

  validation {
    condition     = can(regex("^(t3|t3a)\\.", var.instance_type))
    error_message = "instance_type must be an x86_64 family (t3 or t3a), because the AMI is x86_64 only."
  }
}




