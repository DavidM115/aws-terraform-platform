output "bucket_arn" {
  description = "ARN of the bucket, used in policies and as a flow log destination"
  value       = aws_s3_bucket.s3_bucket.arn
}

output "bucket_id" {
  description = "ID of the S3 Bucket."
  value       = aws_s3_bucket.s3_bucket.id
}