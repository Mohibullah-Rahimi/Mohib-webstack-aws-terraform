# providers.tf
# Configure Terraform and AWS provider
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Use provider config that can read credentials from AWS CLI profile or environment variables.
# If you want to use an assume role, replace/profile or add `assume_role` block here.
provider "aws" {
  region  = var.aws_region
  # Optionally use a named profile (set var.aws_profile = "" to use env vars)
  profile = var.aws_profile
  # You can also rely on AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY env vars.
  default_tags {
    tags = {
      CreatedBy = "Mohibullah-Rahimi"
      Project   = var.project_name
    }
  }
}