variable "aws_region" {
  description = "AWS region"
  type        = string
}
variable "domain_name" {
  description = "Your domain name"
  type        = string
}

variable "root_zone_id" {
  description = "Your root zone id"
  type        = string
}

variable "subdomain_zone_id" {
  description = "Hosted Zone ID for the subdomain"
  type        = string
}
variable "vpc_name" {
  description = "The name of the vpc"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
}

variable "aws_profile" {
  description = "AWS Profile"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "public_subnets_cidr" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "public_subnets_az" {
  description = "Availability zones for public subnets"
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "private_subnets_az" {
  description = "Availability zones for private subnets"
  type        = list(string)
}

variable "custom_ami" {
  description = "AMI string name"
  type        = string
}

variable "app_port" {
  description = "Application running port"
  type        = string
}

# RDS Variables
variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_engine" {
  description = "Database engine (e.g., mysql, postgres)"
  type        = string
  default     = "mysql"
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Database allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_parameter_group_family" {
  description = "Database parameter group family"
  type        = string
  default     = "mysql5.7" # Adjust for PostgreSQL or MariaDB if needed
}


variable "asg_desired_capacity" {
  default     = 5
  type        = number
  description = "Desired capacity for the auto scaling group"
}

variable "asg_min_size" {
  default     = 3
  type        = number
  description = "Minimum size for the auto scaling group"
}

variable "asg_max_size" {
  default     = 10
  type        = number
  description = "Maximum size for the auto scaling group"
}

variable "scale_up_evaluation_periods" {
  default     = 1
  type        = number
  description = "Number of evaluation periods for scale up"
}

variable "scale_up_period" {
  default     = 10
  type        = number
  description = "Period in seconds for scale up metrics"
}

variable "scale_up_threshold" {
  default     = 13
  type        = number
  description = "CPU threshold for scale up"
}

variable "scale_down_evaluation_periods" {
  default     = 1
  type        = number
  description = "Number of evaluation periods for scale down"
}

variable "scale_down_period" {
  default     = 10
  type        = number
  description = "Period in seconds for scale down metrics"
}

variable "scale_down_threshold" {
  default     = 10
  type        = number
  description = "CPU threshold for scale down"
}

variable "cooldown" {
  default     = 60
  type        = number
  description = "Cooldown period in seconds"
}

variable "scale_up_adjustment" {
  default     = 1
  type        = number
  description = "Adjustment value for scale up"
}

variable "scale_down_adjustment" {
  default     = -1
  type        = number
  description = "Adjustment value for scale down"
}

variable "health_check_grace_period" {
  default     = 300
  type        = number
  description = "Health check grace period in seconds"
}

variable "health_check_interval" {
  default     = 10
  type        = number
  description = "Health check interval in seconds"
}

variable "health_check_timeout" {
  default     = 5
  type        = number
  description = "Health check timeout in seconds"
}

variable "healthy_threshold" {
  default     = 2
  type        = number
  description = "Number of consecutive successful health checks"
}

variable "unhealthy_threshold" {
  default     = 2
  type        = number
  description = "Number of consecutive failed health checks"
}