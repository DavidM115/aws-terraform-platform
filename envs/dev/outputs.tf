output "instance_id" {
  description = "ID of the application EC2 instance."
  value       = module.compute.instance_id
}

output "vpc_id" {
  description = "ID of the VPC (vpc-...), used by the storage module's flow log and by debugging commands."
  value       = module.network.vpc_id
}

output "nat_gateway_ids" {
  description = "NAT gateway IDs."
  value       = module.network.nat_gateway_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.network.public_subnets_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.network.private_subnets_ids
}

output "instance_role_name" {
  description = "Name of the IAM role attached to the instance."
  value       = module.compute.aws_iam_role_name
}