# ============================================
# RDS DATABASE CONFIGURATION
# MariaDB Multi-AZ for Laravel Application
# ============================================

# ============================================
# DB Subnet Group
# Required for Multi-AZ - spans 2 AZs
# ============================================

resource "aws_db_subnet_group" "main" {
  name        = "devops-db-subnet-group"
  description = "Database subnet group for RDS Multi-AZ"
  subnet_ids = [
    aws_subnet.private_db_1.id,
    aws_subnet.private_db_2.id
  ]

  tags = {
    Name        = "devops-db-subnet-group"
    Project     = "Laravel-Terraform"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ============================================
# DB Parameter Group
# MariaDB 10.11 configuration for Laravel
# ============================================

resource "aws_db_parameter_group" "main" {
  name        = "devops-mariadb-params"
  family      = "mariadb10.11"
  description = "Custom parameter group for MariaDB 10.11"

  # Character set for UTF-8 support (Laravel requirement)
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  # Connection settings
  parameter {
    name  = "max_connections"
    value = "100"
  }

  # Laravel recommended settings
  parameter {
    name  = "max_allowed_packet"
    value = "67108864" # 64MB
  }

  tags = {
    Name        = "devops-mariadb-params"
    Project     = "Laravel-Terraform"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ============================================
# RDS Instance - MariaDB Multi-AZ
# ============================================

resource "aws_db_instance" "main" {
  # Instance Configuration
  identifier     = "devops-laravel-db"
  engine         = "mariadb"
  engine_version = "10.11"
  instance_class = "db.t3.micro"

  # Storage Configuration
  allocated_storage     = 20
  max_allocated_storage = 100 # Auto-scaling up to 100GB
  storage_type          = "gp3"
  storage_encrypted     = true

  # Database Configuration
  db_name  = "laravel"
  username = "admin"
  password = "ChangeThisPassword123!" # We'll use Secrets Manager later

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  # High Availability
  multi_az = true

  # Backup Configuration
  backup_retention_period = 7
  backup_window           = "03:00-04:00" # 3-4 AM UTC
  maintenance_window      = "mon:04:00-mon:05:00"

  # Parameter and Option Groups
  parameter_group_name = aws_db_parameter_group.main.name

  # Deletion Protection
  deletion_protection = false # For learning - set true in production
  skip_final_snapshot = true  # For learning - set false in production

  # Performance Insights (optional - additional cost)
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  tags = {
    Name        = "devops-laravel-db"
    Project     = "Laravel-Terraform"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ============================================
# Outputs
# ============================================

output "rds_endpoint" {
  value       = aws_db_instance.main.endpoint
  description = "RDS instance endpoint"
  sensitive   = false
}

output "rds_address" {
  value       = aws_db_instance.main.address
  description = "RDS instance address (without port)"
  sensitive   = false
}

output "rds_port" {
  value       = aws_db_instance.main.port
  description = "RDS instance port"
}

output "rds_database_name" {
  value       = aws_db_instance.main.db_name
  description = "Database name"
}

output "rds_arn" {
  value       = aws_db_instance.main.arn
  description = "RDS instance ARN"
}

