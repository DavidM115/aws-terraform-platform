output "aws_s3_bucket" {
  description = "ARN of the S3 Logging Bucket"
  value       = aws_s3_bucket.logging.arn
}