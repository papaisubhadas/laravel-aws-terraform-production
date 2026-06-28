# First Terraform Configuration
# Purpose: Learn basic syntax

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1" # Change to your preferred region
}

# Example: Create a VPC (we'll expand this)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16" # 65,536 IPs
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "devops-journey-vpc"
    Project     = "Laravel-Terraform"
    Environment = "Learning"
    ManagedBy   = "Terraform"
  }
}

# Output to see the VPC ID
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "The CIDR block of the VPC"
}
