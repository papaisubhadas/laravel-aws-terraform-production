# Public Subnets (for ALB)
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24" # 256 IPs
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name      = "devops-public-subnet-1a"
    Type      = "Public"
    Project   = "Laravel-Terraform"
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24" # 256 IPs
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name      = "devops-public-subnet-1b"
    Type      = "Public"
    Project   = "Laravel-Terraform"
    ManagedBy = "Terraform"
  }
}



# Private Subnets (for EC2 application servers)
resource "aws_subnet" "private_app_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name      = "devops-private-app-subnet-1a"
    Type      = "Private"
    Tier      = "Application"
    Project   = "Laravel-Terraform"
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "private_app_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name      = "devops-private-app-subnet-1b"
    Type      = "Private"
    Tier      = "Application"
    Project   = "Laravel-Terraform"
    ManagedBy = "Terraform"
  }
}



# Private Subnets (for RDS database)
resource "aws_subnet" "private_db_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name      = "devops-private-db-subnet-1a"
    Type      = "Private"
    Tier      = "Database"
    Project   = "Laravel-Terraform"
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "private_db_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name      = "devops-private-db-subnet-1b"
    Type      = "Private"
    Tier      = "Database"
    Project   = "Laravel-Terraform"
    ManagedBy = "Terraform"
  }
}


# Outputs
output "public_subnet_ids" {
  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
  description = "IDs of public subnets"
}

output "private_app_subnet_ids" {
  value = [
    aws_subnet.private_app_1.id,
    aws_subnet.private_app_2.id
  ]
  description = "IDs of private application subnets"
}

output "private_db_subnet_ids" {
  value = [
    aws_subnet.private_db_1.id,
    aws_subnet.private_db_2.id
  ]
  description = "IDs of private database subnets"
}