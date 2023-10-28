terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-2"
}


# Create a VPC
resource "aws_vpc" "vpc1024" {
  cidr_block = "10.0.0.0/16"
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw1024" {
  vpc_id = aws_vpc.vpc1024.id
}

# Create a subnet within the VPC
resource "aws_subnet" "subnet1024" {
  vpc_id     = aws_vpc.vpc1024.id
  cidr_block = "10.0.1.0/24"
}

# Create a route table for the public subnet
resource "aws_route_table" "art1024" {
  vpc_id = aws_vpc.vpc1024.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1024.id
  }
}

# Associate the subnet with the route table
resource "aws_route_table_association" "arta1024" {
  subnet_id      = aws_subnet.subnet1024.id
  route_table_id = aws_route_table.art1024.id
}


# Create a security group for the EC2 instance
resource "aws_security_group" "sg1024" {
  name        = "secutyGroup1024"
  description = "Sample security group"
  vpc_id      = aws_vpc.vpc1024.id

  # Define your security group rules
  # Allow SSH traffic (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS traffic (port 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "instance1024" {
  ami             = "ami-09d9029d9fc5e5238" # fetched ami id for free tier on us-east-2
  instance_type   = "t2.micro"                      # need to update as per need
  subnet_id       = aws_subnet.subnet1024.id
  key_name        = "aws-key" # created my key on console
  security_groups = [aws_security_group.sg1024.id]
  associate_public_ip_address = true

  tags = {
    Name = "aws-ec2-1024"
  }
}


# Create CloudWatch Alarm for CPU Utilization
resource "aws_cloudwatch_metric_alarm" "cwm1024" {
  alarm_name          = "ExampleInstanceCPUAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric checks for high CPU utilization on the EC2 instance."

  alarm_actions = [aws_sns_topic.snst1024.arn]

  dimensions = {
    InstanceId = aws_instance.instance1024.id
  }
}

# Create an SNS topic for CloudWatch Alarms
resource "aws_sns_topic" "snst1024" {
  name = "ExampleCloudWatchAlarms"
}

# Define an output to display the public IP address of the EC2 instance
output "instance_ip" {
  value = aws_instance.instance1024.public_ip
}

