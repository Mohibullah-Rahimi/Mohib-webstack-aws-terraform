# modules/db/variables.tf
variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "db_subnet_ids" {
  description = "Private subnet IDs for RDS"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "db_username" {
  description = "RDS master username"
  type        = string
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "db_sg_id" {
  description = "DB security group ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}