# backend.tf
# Remote backend configuration for Terraform state.
# NOTE: Terraform backend cannot use variables; replace placeholders below before running `terraform init`.
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"   # CHANGE_ME: create/replace with your bucket
    key            = "terraform-aws-web-stack/terraform.tfstate"
    region         = "us-east-1"                   # CHANGE_ME e.g. "us-east-1"
    dynamodb_table = "terraform-locks-table"        # CHANGE_ME: create/replace
    encrypt        = true
  }
}