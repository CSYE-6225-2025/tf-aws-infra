variable "aws_region" {
  description = "AWS region"
  type        = string
}

# variable "aws_secret_access" {
#   description = "AWS secret key"
#   type        = string
# }
# variable "aws_access" {
#   description = "AWS access key"
#   type        = string
# }


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