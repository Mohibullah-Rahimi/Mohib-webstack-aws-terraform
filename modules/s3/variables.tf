# modules/s3/variables.tf
variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}