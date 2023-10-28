provider "aws" {
  region = "us-west-2"  # Specify your desired AWS region
}

# Define an AWS launch configuration
resource "aws_launch_configuration" "example" {
  name_prefix          = "example-"
  image_id             = "ami-0123456789abcdef0"  # Replace with your desired AMI
  instance_type        = "t2.micro"  # Replace with your desired instance type
  key_name             = "your-key-pair-name"  # Replace with your key pair name
  security_groups      = ["sg-0123456789abcdef0"]  # Replace with your security group IDs
  user_data            = <<-EOF
    #!/bin/bash
    # Your user data script here
  EOF

  # Optional: You can add more configuration options, such as IAM instance profile, block device mappings, etc.
}

# Create an Auto Scaling Group
resource "aws_autoscaling_group" "example" {
  name                 = "example-asg"
  launch_configuration = aws_launch_configuration.example.name
  min_size             = 2  # Minimum number of instances
  max_size             = 5  # Maximum number of instances
  desired_capacity     = 2  # Desired number of instances

  # Define VPC and subnet information
  vpc_zone_identifier  = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]  # Replace with your subnet IDs

  # Optional: You can add more configuration options, such as tags, health checks, and load balancer settings.
}

# Create a scaling policy to adjust the ASG based on metrics
resource "aws_autoscaling_policy" "example" {
  name                   = "example-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.example.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50  # Set your desired target CPU utilization
  }
}

# Optionally, you can define CloudWatch alarms and policies for scaling actions based on specific metrics.

# Define the scale-up alarm
resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_name          = "example-scale-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period             = 300
  statistic           = "Average"
  threshold           = 80  # Set your desired threshold for scaling up
  alarm_description   = "Scale up when CPU exceeds 80%"
  alarm_action {
    type                 = "autoscaling:EC2_INSTANCE_TERMINATE"
  }
  alarm_action {
    type                 = "autoscaling:EC2_INSTANCE_TERMINATE"
  }
}

# Define the scale-down alarm
resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_name          = "example-scale-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period             = 300
  statistic           = "Average"
  threshold           = 20  # Set your desired threshold for scaling down
  alarm_description   = "Scale down when CPU falls below 20%"
  alarm_action {
    type                 = "autoscaling:EC2_INSTANCE_TERMINATE"
  }
}
