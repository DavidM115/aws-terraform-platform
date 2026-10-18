# Data source to fetch available AZs in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

# Create a VPC with a /16 CIDR (default)
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  # DNS Support
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project}-${var.environment}-vpc"
    Environment = var.environment
  }
}

# Retrieve current AWS region
data "aws_region" "current" {}

# S3 gateway endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [for rt in aws_route_table.private : rt.id]

  tags = {
    Name = "${var.project}-${var.environment}-s3endpoint"
  }
}


# Local variables to define public and private subnets across the first 2 AZs
locals {
  # Take the first 2 availability zones
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  public_subnets = {
    for idx, az in local.azs : az => {
      az         = az
      cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, idx) # e.g., 10.0.0.0/24, 10.0.1.0/24
    }
  }

  private_subnets = {
    for idx, az in local.azs : az => {
      az         = az
      cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, idx + 10) # e.g., 10.0.10.0/24, 10.0.11.0/24
    }
  }

  nat_keys = var.single_nat_gateway ? slice(local.azs, 0, 1) : local.azs

}


#Create two public subnets in the available AZs
resource "aws_subnet" "public" {
  for_each          = local.public_subnets
  vpc_id            = aws_vpc.main.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr_block

  # Automatically assigns a public IPv4 address to any EC2 instance launched into this subnet.
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-${var.environment}-public-${each.key}"
  }
}

# Create two private subnets in the available AZs
resource "aws_subnet" "private" {
  for_each          = local.private_subnets
  vpc_id            = aws_vpc.main.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr_block

  tags = {
    Name = "${var.project}-${var.environment}-private-${each.key}"

  }
}

# IGW: One VPC can only be attached to one IGW and vice versa.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-${var.environment}-igw"
  }
}

resource "aws_eip" "nateip" {
  for_each = toset(local.nat_keys)
  domain   = "vpc"

  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.project}-${var.environment}-nateip-${each.key}"
  }
}



# NAT GW
resource "aws_nat_gateway" "natgw" {
  for_each      = toset(local.nat_keys)
  allocation_id = aws_eip.nateip[each.key].allocation_id
  subnet_id     = aws_subnet.public[each.key].id


  # Explicit dependency as IGW needs to exist first
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.project}-${var.environment}-natgw-${each.key}"
  }
}

# Public Route Table & Association
resource "aws_route_table" "public" {
  for_each = local.public_subnets
  vpc_id   = aws_vpc.main.id

  # Inline route targeting the IGW route
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project}-${var.environment}-publicrt-${each.key}"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[each.key].id
}

# Private Route Table & Association
resource "aws_route_table" "private" {
  for_each = local.private_subnets
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = lookup(aws_nat_gateway.natgw, each.value.az, aws_nat_gateway.natgw[local.nat_keys[0]]).id
  }

  tags = {
    Name = "${var.project}-${var.environment}-privatert-${each.key}"
  }
}
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}


