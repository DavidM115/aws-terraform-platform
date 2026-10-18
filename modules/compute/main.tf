# Create a security group for the EC2 instance
resource "aws_security_group" "ec2_sg" {
  vpc_id      = var.vpc_id
  description = "SG with no ingress and egress rules"
}

# Create a security group egress rule since TF removes it by default
resource "aws_vpc_security_group_egress_rule" "ec2_egress_rule" {
  security_group_id = aws_security_group.ec2_sg.id

  description = "SSM agent and package repository access"

  cidr_ipv4   = "10.0.0.0/8"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
  tags = {
    Name = "${var.project}-${var.environment}-ec2-egress-rule"
  }
}

# --- IAM Role for EC2 (SSM Permissions) ---
# Create an IAM role for the EC2 instance
resource "aws_iam_role" "ssm_ec2_role" {
  name = "${var.project}-${var.environment}-ssm-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "${var.project}-${var.environment}-ssm-ec2-role"
  }
}

# Attach the AmazonSSMManagedInstanceCore policy to the role
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ssm_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create an instance profile for the EC2 instance
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "${var.project}-${var.environment}-ssm-instance-profile"
  role = aws_iam_role.ssm_ec2_role.name
}

# An Amazon Linux 2023 AMI looked up through SSM parameter
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64" # Validation depends on this
}

# Create the private EC2 instance
resource "aws_instance" "app" {
  ami                         = data.aws_ssm_parameter.al2023.insecure_value
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = false # Crucial for zero-trust (no public IP)
  iam_instance_profile        = aws_iam_instance_profile.ssm_instance_profile.name

  lifecycle {
    # Option A: Prevent Terraform from replacing the EC2 instance when the SSM Parameter updates
    ignore_changes = [ami]
  }

  root_block_device {
    encrypted = true # Enable EBS encryption
  }

  metadata_options {
    http_tokens = "required" # Requires IMDSv2
  }
  tags = {
    Name = "${var.project}-${var.environment}-app"
  }
}
