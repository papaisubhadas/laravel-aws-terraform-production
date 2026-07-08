# ============================================
# EC2 LAUNCH TEMPLATE
# Template for Auto Scaling Group instances
# ============================================

# ============================================
# Data Source - Latest Ubuntu 24.04 LTS AMI
# ============================================

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu official)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# ============================================
# Launch Template
# ============================================

resource "aws_launch_template" "main" {
  name_prefix   = "devops-laravel-lt-"
  description   = "Launch template for Laravel application servers"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  # IAM instance profile (allows EC2 to access AWS services)
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  # Network configuration
  network_interfaces {
    associate_public_ip_address = false # Instances in private subnets
    delete_on_termination       = true
    security_groups             = [aws_security_group.ec2.id]
  }

  # User data script (base64 encoded)
  user_data = base64encode(file("${path.module}/scripts/user-data.sh"))

  # Instance metadata options (IMDSv2 for security)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Enforce IMDSv2
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  # Monitoring
  monitoring {
    enabled = true # Detailed CloudWatch monitoring
  }

  # EBS optimization (better I/O performance)
  ebs_optimized = true

  # Tag specifications for instances
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "devops-laravel-ec2"
      Project     = "Laravel-Terraform"
      Environment = "Production"
      ManagedBy   = "Terraform-ASG"
      Application = "Laravel"
    }
  }

  # Tag specifications for volumes
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name      = "devops-laravel-ec2-volume"
      Project   = "Laravel-Terraform"
      ManagedBy = "Terraform"
    }
  }

  # Lifecycle
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "devops-laravel-launch-template"
    Project     = "Laravel-Terraform"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ============================================
# Outputs
# ============================================

output "launch_template_id" {
  value       = aws_launch_template.main.id
  description = "ID of the launch template"
}

output "launch_template_name" {
  value       = aws_launch_template.main.name
  description = "Name of the launch template"
}

output "launch_template_latest_version" {
  value       = aws_launch_template.main.latest_version
  description = "Latest version number of launch template"
}

output "ami_id" {
  value       = data.aws_ami.ubuntu.id
  description = "AMI ID being used (Ubuntu 24.04 LTS)"
}

output "ami_name" {
  value       = data.aws_ami.ubuntu.name
  description = "AMI name"
}