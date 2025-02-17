# AWS Region
variable "region" {
  description = "AWS region to create resources"
  default     = "us-east-1"
}

# AWS Profile for demo profile
variable "aws_profile" {
  description = "AWS profile to use"
  default     = "demo"
}

# VPC CIDR block
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# Availability Zones
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# Subnet CIDR Blocks for public and private subnets
variable "subnets" {
  description = "Map of public and private subnet CIDR blocks"
  type = map(object({
    public  = string
    private = string
  }))
  default = {
    subnet_1 = { public = "10.0.0.0/24", private = "10.0.1.0/24" }
    subnet_2 = { public = "10.0.2.0/24", private = "10.0.3.0/24" }
    subnet_3 = { public = "10.0.4.0/24", private = "10.0.5.0/24" }
  }
}

# Tags to apply to resources
variable "tags" {
  description = "Default tags for resources"
  type        = map(string)
  default = {
    Environment = "Demo"
    Project     = "My Webapp terraform"
  }
}
