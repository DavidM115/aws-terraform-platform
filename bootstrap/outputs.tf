output "state_bucket_name" {
  description = "Name of the remote state bucket."
  value       = aws_s3_bucket.state.id
}

output "state_bucket_arn" {
  description = "ARN of the remote state bucket (used later in IAM policies for the pipeline roles)."
  value       = aws_s3_bucket.state.arn
}

# Ready-to-use partial backend config. Generate the file with:
#   terraform output -raw backend_hcl > backend.hcl
output "backend_hcl" {
  description = "Contents for backend.hcl (partial backend configuration)."
  value       = <<-EOT
    bucket = "${aws_s3_bucket.state.id}"
    region = "${var.aws_region}"
  EOT
}
