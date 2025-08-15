# modules/vpc/variables.tf
variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "az_count" {
  description = "Number of AZs to create subnets in"
  type        = number
  default     = 2
}