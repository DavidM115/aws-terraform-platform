# Same region as the S3 backend
aws_region = "us-west-2"

project = "aws-tf-platform"

environment = "dev"

single_nat_gateway = true

instance_type = "t3.micro"

# Storage variable inputs
force_destroy = true

log_retention_days = 10

noncurrent_object_retention_days = 5