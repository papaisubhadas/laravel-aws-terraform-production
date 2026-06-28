# Internet Gateway (for public subnets)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "devops-igw"
    Project   = "Laravel-Terraform"
    ManagedBy = "Terraform"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                  # All internet traffic
    gateway_id = aws_internet_gateway.main.id # Goes through IGW
  }

  tags = {
    Name      = "devops-public-rt"
    Type      = "Public"
    Project   = "Laravel-Terraform"
    ManagedBy = "Terraform"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Note: NAT Gateway costs money, we'll add it later when needed
# For now, private subnets will use default route table