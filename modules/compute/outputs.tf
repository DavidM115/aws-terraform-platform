output "instance_id" {
  value       = aws_instance.app.id
  description = "ID of the application EC2 instance"

}

output "aws_iam_role_name" {
  value       = aws_iam_role.ssm_ec2_role.name
  description = "Name of the EC2 SSM role"
}

output "aws_iam_role_ARN" {
  value       = aws_iam_role.ssm_ec2_role.arn
  description = "ARN of the EC2 SSM role"
}