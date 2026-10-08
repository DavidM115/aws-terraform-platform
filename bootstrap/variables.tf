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

variable "monthly_budget_usd" {
  description = "Monthly cost budget in USD. Alerts fire at 80% actual and 100% forecasted."
  type        = number
  default     = 10

  validation {
    condition     = var.monthly_budget_usd > 0
    error_message = "monthly_budget_usd must be greater than 0."
  }
}

variable "budget_email" {
  description = "Email address that receives budget alerts. Set it in terraform.tfvars (git-ignored)."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.budget_email))
    error_message = "budget_email must be a valid email address."
  }
}
