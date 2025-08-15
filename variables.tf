# variables.tf - root variables (sensible defaults)
variable "aws_region" {
  description = "AWS region to deploy"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name to use (leave empty to use env credentials)"
  type        = string
  default     = "default"
}

variable "project_name" {
  description = "Project name prefix used in resource names and tags"
  type        = string
  default     = "mohib-webstack"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "key_name" {
  description = "EC2 key pair name created in AWS for SSH access"
  type        = string
  default     = "ec2-keypair" # CHANGE_ME: set your key pair name
}

variable "instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t3.micro"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "RDS master password (sensitive)"
  type        = string
  sensitive   = true
}

# Optional: number of AZs (2 recommended for high-availability)
variable "az_count" {
  description = "Number of Availability Zones to use"
  type        = number
  default     = 2
}