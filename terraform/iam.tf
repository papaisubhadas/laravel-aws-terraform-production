# ============================================
# IAM ROLE FOR EC2 INSTANCES
# Allows EC2 instances to securely access AWS services
# ============================================

# ============================================
# IAM Role
# ============================================

resource "aws_iam_role" "ec2_role" {
  name        = "devops-laravel-ec2-role"
  description = "IAM role for Laravel EC2 instances to access AWS services"

  # Trust policy - allows EC2 service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "devops-laravel-ec2-role"
    Project     = "Laravel-Terraform"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ============================================
# AWS Managed Policy - Systems Manager
# Allows AWS Systems Manager to manage instances
# ============================================

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ============================================
# Custom Policy - CloudWatch Logs
# Allows EC2 to send logs to CloudWatch
# ============================================

resource "aws_iam_role_policy" "cloudwatch_logs" {
  name = "cloudwatch-logs-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# ============================================
# Instance Profile
# Wrapper to attach IAM role to EC2 instances
# ============================================

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "devops-laravel-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name        = "devops-laravel-ec2-profile"
    Project     = "Laravel-Terraform"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ============================================
# Outputs
# ============================================

output "iam_role_name" {
  value       = aws_iam_role.ec2_role.name
  description = "Name of IAM role for EC2"
}

output "iam_role_arn" {
  value       = aws_iam_role.ec2_role.arn
  description = "ARN of IAM role for EC2"
}

output "iam_instance_profile_name" {
  value       = aws_iam_instance_profile.ec2_profile.name
  description = "Name of IAM instance profile for EC2"
}

output "iam_instance_profile_arn" {
  value       = aws_iam_instance_profile.ec2_profile.arn
  description = "ARN of IAM instance profile"
}