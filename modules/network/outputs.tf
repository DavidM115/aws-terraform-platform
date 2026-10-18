output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the created VPC"
}

output "nat_gateway_ids" {
  description = "Map from availability zone to NAT gateway ID"
  value       = { for az, nat in aws_nat_gateway.natgw : az => nat.id }
}

output "public_subnets_ids" {
  description = "Map from availability zone to public subnet ID"
  value       = { for az, subnet in aws_subnet.public : az => subnet.id }
}
output "private_subnets_ids" {
  description = "Map from availability zone to private subnet ID"
  value       = { for az, subnet in aws_subnet.private : az => subnet.id }
}