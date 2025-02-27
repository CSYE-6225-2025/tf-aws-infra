variable "aws_region" {
  description = "AWS region"
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
  type = list(string)
}

variable "public_subnets_az" {
  type = list(string)
}

variable "private_subnets_cidr" {
  type = list(string)
}

variable "private_subnets_az" {
  type = list(string)
}

variable "custom_ami" {
  description = "AMI string name"
  type        = string
}

variable "app_port" {
  description = "Application running port"
  type        = string
}
