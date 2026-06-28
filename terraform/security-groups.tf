# ============================================
# SECURITY GROUPS
# Three-tier security architecture
# ============================================

# ============================================
# ALB Security Group (Public-facing)
# ============================================

resource "aws_security_group" "alb" {
  name        = "devops-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "devops-alb-sg"
    Tier        = "Public"
    Project     = "Laravel-Terraform"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ============================================
# EC2 Security Group (Application Tier)
# ============================================

resource "aws_security_group" "ec2" {
  name        = "devops-ec2-sg"
  description = "Security group for EC2 application servers"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "devops-ec2-sg"
    Tier        = "Application"
    Project     = "Laravel-Terraform"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ============================================
# RDS Security Group (Database Tier)
# ============================================

resource "aws_security_group" "rds" {
  name        = "devops-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "devops-rds-sg"
    Tier        = "Database"
    Project     = "Laravel-Terraform"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ============================================
# SECURITY GROUP RULES (Separate from SG creation)
# ============================================

# ALB Inbound Rules
resource "aws_security_group_rule" "alb_http_inbound" {
  type              = "ingress"
  description       = "HTTP from Internet"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_https_inbound" {
  type              = "ingress"
  description       = "HTTPS from Internet"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

# ALB Outbound Rules
resource "aws_security_group_rule" "alb_all_outbound" {
  type              = "egress"
  description       = "Allow all outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

# EC2 Inbound Rules
resource "aws_security_group_rule" "ec2_http_from_alb" {
  type                     = "ingress"
  description              = "HTTP from ALB only"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ec2.id
}

# EC2 Outbound Rules
resource "aws_security_group_rule" "ec2_https_outbound" {
  type              = "egress"
  description       = "HTTPS for updates"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "ec2_mysql_to_rds" {
  type                     = "egress"
  description              = "MySQL to RDS"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
  security_group_id        = aws_security_group.ec2.id
}

# RDS Inbound Rules
resource "aws_security_group_rule" "rds_mysql_from_ec2" {
  type                     = "ingress"
  description              = "MySQL from EC2 only"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2.id
  security_group_id        = aws_security_group.rds.id
}

# ============================================
# Outputs
# ============================================

output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "ID of ALB security group"
}

output "ec2_security_group_id" {
  value       = aws_security_group.ec2.id
  description = "ID of EC2 security group"
}

output "rds_security_group_id" {
  value       = aws_security_group.rds.id
  description = "ID of RDS security group"
}