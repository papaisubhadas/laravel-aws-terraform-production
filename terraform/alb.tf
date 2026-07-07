# ============================================
# APPLICATION LOAD BALANCER CONFIGURATION
# Internet-facing load balancer for Laravel application
# ============================================

# ============================================
# Application Load Balancer
# ============================================

resource "aws_lb" "main" {
  name               = "devops-laravel-alb"
  internal           = false # Internet-facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]

  # Must be in public subnets (needs internet access)
  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  # Enable deletion protection in production
  enable_deletion_protection = false # For learning - set true in production

  # Enable cross-zone load balancing (distributes traffic evenly)
  enable_cross_zone_load_balancing = true

  # Access logs (optional - costs S3 storage)
  # access_logs {
  #   bucket  = aws_s3_bucket.alb_logs.id
  #   enabled = true
  # }

  tags = {
    Name        = "devops-laravel-alb"
    Project     = "Laravel-Terraform"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ============================================
# Target Group
# Group of EC2 instances to receive traffic
# ============================================

resource "aws_lb_target_group" "main" {
  name     = "devops-laravel-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  # Target type (instance, ip, or lambda)
  target_type = "instance"

  # Deregistration delay (how long to wait before removing instance)
  deregistration_delay = 30 # seconds

  # Health check configuration
  health_check {
    enabled             = true
    healthy_threshold   = 2              # Consecutive successes to be healthy
    unhealthy_threshold = 2              # Consecutive failures to be unhealthy
    interval            = 30             # Seconds between checks
    matcher             = "200,302"      # HTTP status codes to consider healthy
    path                = "/"            # Health check path
    port                = "traffic-port" # Use same port as target
    protocol            = "HTTP"
    timeout             = 5 # Seconds to wait for response
  }

  # Stickiness (session affinity) - optional
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400 # 24 hours in seconds
    enabled         = false # Disable for now, enable if needed for Laravel sessions
  }

  tags = {
    Name        = "devops-laravel-tg"
    Project     = "Laravel-Terraform"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ============================================
# HTTP Listener (Port 80)
# Listens for HTTP traffic and forwards to target group
# ============================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  # Default action: forward to target group
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  # In Week 4, we can add HTTPS listener and redirect HTTP → HTTPS
}

# ============================================
# Outputs
# ============================================

output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "DNS name of the Application Load Balancer"
}

output "alb_arn" {
  value       = aws_lb.main.arn
  description = "ARN of the Application Load Balancer"
}

output "alb_zone_id" {
  value       = aws_lb.main.zone_id
  description = "Zone ID of the Application Load Balancer (for Route53)"
}

output "target_group_arn" {
  value       = aws_lb_target_group.main.arn
  description = "ARN of the Target Group"
}

output "target_group_name" {
  value       = aws_lb_target_group.main.name
  description = "Name of the Target Group"
}