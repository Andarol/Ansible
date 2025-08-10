variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability zone for subnets"
  type        = string
  default     = "eu-central-1a"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-04e601abe3e1a910f" # Ubuntu 22.04 LTS
}

variable "instance_type" {
  description = "Instance type for ASG instances"
  type        = string
  default     = "t3.micro"  # Free tier eligible instance type
}

variable "key_name" {
  description = "SSH key name"
  type        = string
  default     = "my_aws"
}

variable "public_key_path" {
  description = "Path to public key file"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "scheduled_time" {
  description = "Time for scheduled scaling action (RFC3339 format, e.g., 2025-08-10T15:00:00Z)"
  type        = string
  default     = "2025-08-11T10:00:00Z"  
}

variable "security_group_name" {
  description = "Name for the security group"
  type        = string
  default     = "asg-security-group"  # Changed from wp-security-group to match ASG context
}

# ASG Configuration Variables
variable "asg_min_size" {
  description = "Minimum size for the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum size for the Auto Scaling Group"
  type        = number
  default     = 5
}

variable "asg_desired_capacity" {
  description = "Desired capacity for the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for scaling"
  type        = number
  default     = 70
}
