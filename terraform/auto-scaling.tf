# ============================================
# AUTO SCALING GROUP
# Automatically manages EC2 instances for high availability
# ============================================

# ============================================
# Auto Scaling Group
# ============================================

resource "aws_autoscaling_group" "main" {
  name                      = "devops-laravel-asg"
  min_size                  = 2     # Always keep at least 2 instances running
  max_size                  = 6     # Can scale up to 6 instances during high traffic
  desired_capacity          = 2     # Start with 2 instances
  health_check_type         = "ELB" # Use ALB health checks (not just EC2 status)
  health_check_grace_period = 300   # Wait 5 minutes before health checks (user data needs time)

  # Deploy in private subnets across multiple AZs
  vpc_zone_identifier = [
    aws_subnet.private_app_1.id,
    aws_subnet.private_app_2.id
  ]

  # Use the launch template we created on Day 8
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest" # Always use latest version of template
  }

  # Attach to ALB target group (instances auto-register)
  target_group_arns = [aws_lb_target_group.main.arn]

  # Instance refresh configuration (for rolling updates)
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50  # Always keep 50% of instances healthy during updates
      instance_warmup        = 300 # Wait 5 minutes for new instances to warm up
    }
  }

  # Termination policies (which instances to terminate first when scaling down)
  termination_policies = ["OldestInstance", "Default"]

  # Enable metrics collection
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  # Tags for Auto Scaling Group
  tag {
    key                 = "Name"
    value               = "devops-laravel-asg-instance"
    propagate_at_launch = true # Apply tag to launched instances
  }

  tag {
    key                 = "Project"
    value               = "Laravel-Terraform"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Production"
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform-ASG"
    propagate_at_launch = true
  }

  tag {
    key                 = "Application"
    value               = "Laravel"
    propagate_at_launch = true
  }

  # Lifecycle
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity] # Allow manual scaling without Terraform overwriting
  }
}

# ============================================
# Auto Scaling Policies
# ============================================

# Scale UP policy (add instances)
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "devops-laravel-scale-up"
  scaling_adjustment     = 2 # Add 2 instances at a time
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300 # Wait 5 minutes before allowing another scale-up
  autoscaling_group_name = aws_autoscaling_group.main.name
}

# Scale DOWN policy (remove instances)
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "devops-laravel-scale-down"
  scaling_adjustment     = -1 # Remove 1 instance at a time
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300 # Wait 5 minutes before allowing another scale-down
  autoscaling_group_name = aws_autoscaling_group.main.name
}

# ============================================
# CloudWatch Alarms for Auto Scaling
# ============================================

# Alarm: High CPU (trigger scale UP)
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "devops-laravel-high-cpu"
  alarm_description   = "Triggers when average CPU utilization exceeds 70%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2 # Alert if true for 2 consecutive periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120 # Check every 2 minutes
  statistic           = "Average"
  threshold           = 70 # 70% CPU

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  # Trigger scale-up policy
  alarm_actions = [aws_autoscaling_policy.scale_up.arn]

  tags = {
    Name        = "devops-laravel-high-cpu-alarm"
    Project     = "Laravel-Terraform"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Alarm: Low CPU (trigger scale DOWN)
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "devops-laravel-low-cpu"
  alarm_description   = "Triggers when average CPU utilization is below 20%"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2 # Alert if true for 2 consecutive periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120 # Check every 2 minutes
  statistic           = "Average"
  threshold           = 20 # 20% CPU

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  # Trigger scale-down policy
  alarm_actions = [aws_autoscaling_policy.scale_down.arn]

  tags = {
    Name        = "devops-laravel-low-cpu-alarm"
    Project     = "Laravel-Terraform"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ============================================
# Outputs
# ============================================

output "autoscaling_group_id" {
  value       = aws_autoscaling_group.main.id
  description = "ID of the Auto Scaling Group"
}

output "autoscaling_group_name" {
  value       = aws_autoscaling_group.main.name
  description = "Name of the Auto Scaling Group"
}

output "autoscaling_group_arn" {
  value       = aws_autoscaling_group.main.arn
  description = "ARN of the Auto Scaling Group"
}

output "scale_up_policy_arn" {
  value       = aws_autoscaling_policy.scale_up.arn
  description = "ARN of scale-up policy"
}

output "scale_down_policy_arn" {
  value       = aws_autoscaling_policy.scale_down.arn
  description = "ARN of scale-down policy"
}

output "high_cpu_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.high_cpu.arn
  description = "ARN of high CPU CloudWatch alarm"
}

output "low_cpu_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.low_cpu.arn
  description = "ARN of low CPU CloudWatch alarm"
}