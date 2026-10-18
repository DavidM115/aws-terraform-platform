variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "project" {
  description = "Short project name, used as a prefix in resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,30}$", var.project))
    error_message = "project name must be 3-30 characters: lowercase letters, numbers, and hyphens only."
  }
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, prod)"
}

variable "single_nat_gateway" {
  description = "true: one shared NAT gateway (cheaper, but one AZ outage cuts off the private subnets). false: one NAT gateway per AZ (more resilient, costs more)."
  type        = bool
}