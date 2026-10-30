output "log_bucket_arn" {
  description = "ARN of the log bucket, used in policies and as a flow log destination"
  value       = module.vpc_log_bucket.bucket_arn
}

output "log_bucket_id" {
  description = "ID of the log Bucket."
  value       = module.vpc_log_bucket.bucket_id
}

output "backup_bucket_arn" {
  description = "ARN of the backup bucket"
  value       = module.backups_bucket.bucket_arn
}

output "backup_bucket_id" {
  description = "ID of the backup Bucket."
  value       = module.backups_bucket.bucket_id
}

output "flow_log_id" {
  description = "value"
  value       = aws_flow_log.s3_flow_log.id
}