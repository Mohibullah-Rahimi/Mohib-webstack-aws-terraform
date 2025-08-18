# outputs.tf - expose useful outputs

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.web.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS endpoint (sensitive)"
  value       = module.db.rds_endpoint
  sensitive   = true
}

output "s3_bucket_name" {
  description = "S3 bucket created for assets/logs"
  value       = module.s3.bucket_name
}