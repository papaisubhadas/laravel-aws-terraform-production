# ============================================
# NAT Gateway Configuration
# Purpose: Allow private subnets to access internet for updates
# Cost: ~$0.045/hour (~$32/month)
# Note: Will be destroyed after testing to save costs
# ============================================

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "devops-nat-eip"
    Project     = "Laravel-Terraform"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
  # NAT Gateway must be created before EIP can be released
  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway (placed in public subnet for internet access)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id # Must be in public subnet

  tags = {
    Name        = "devops-nat-gateway"
    Project     = "Laravel-Terraform"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
  # Ensure Internet Gateway exists before creating NAT Gateway
  depends_on = [aws_internet_gateway.main]
}


# ============================================
# Private Route Table
# Routes all internet traffic through NAT Gateway
# ============================================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"             # All internet-bound traffic
    nat_gateway_id = aws_nat_gateway.main.id # Goes through NAT Gateway
  }
  tags = {
    Name        = "devops-private-rt"
    Type        = "Private"
    Project     = "Laravel-Terraform"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}


# ============================================
# Route Table Associations - Private App Subnets
# ============================================

resource "aws_route_table_association" "private_app_1" {
  subnet_id      = aws_subnet.private_app_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_app_2" {
  subnet_id      = aws_subnet.private_app_2.id
  route_table_id = aws_route_table.private.id
}


# ============================================
# Route Table Associations - Private DB Subnets
# ============================================

resource "aws_route_table_association" "private_db_1" {
  subnet_id      = aws_subnet.private_db_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_db_2" {
  subnet_id      = aws_subnet.private_db_2.id
  route_table_id = aws_route_table.private.id
}


# ============================================
# Outputs
# ============================================

output "nat_gateway_id" {
  value       = aws_nat_gateway.main.id
  description = "ID of the NAT Gateway"
}

output "nat_gateway_public_ip" {
  value       = aws_eip.nat.public_ip
  description = "Elastic IP address assigned to NAT Gateway"
}

output "private_route_table_id" {
  value       = aws_route_table.private.id
  description = "ID of the private route table"
}