```markdown
# terraform-aws-web-stack

A production-like, modular Terraform project that provisions a highly available 3-tier web application stack on AWS.

Author: Mohibullah Rahimi (GitHub: @Mohibullah-Rahimi)

Overview
- VPC with public and private subnets (multi-AZ)
- Internet Gateway, NAT Gateway, route tables
- Application Load Balancer (ALB)
- Auto Scaling Group of EC2 instances (web tier) with Launch Template
- Private RDS MySQL instance
- S3 bucket for assets / logs
- Terraform remote state (S3 + DynamoDB) — placeholders included
- GitHub Actions workflow for Terraform validation & planning

Important: In This repository there are some placeholders marked with "CHANGE_ME". and I did not commit my secrets. You can use environment variables or GitHub Secrets.

Quickstart (local, VS Code)
1. Install Terraform >= 1.5.0 and AWS CLI.
2. Configure AWS credentials:
   - Option A (recommended for local): use `aws configure --profile <profile>` then set `aws_profile` variable or export AWS_PROFILE.
   - Option B: export AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in your shell.
3. Edit backend configuration (backend.tf) and replace bucket/dynamodb table names where marked CHANGE_ME, or create resources ahead of time.
4. Create a file `terraform.tfvars` or pass variables via CLI. Example `terraform.tfvars`:
   ```
   aws_region = "us-east-1"
   aws_profile = "default"
   project_name = "mohib-webstack"
   key_name = "my-ec2-keypair"          
   db_password = "SOME_STRONG_PASSWORD" 
   ```
   Better: keep db_password out of git and set from environment:
   `export TF_VAR_db_password="SOME_STRONG_PASSWORD"`
5. Initialize & apply:
   ```
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
   ```
6. Cleanup:
   ```
   terraform destroy
   ```

Security & Cost notes
- RDS, NAT, and EC2 resources can incur charges. Use small instance sizes as provided for testing.
- Do not commit real secrets. Use environment variables, a secrets manager, or GitHub repo secrets for CI.

