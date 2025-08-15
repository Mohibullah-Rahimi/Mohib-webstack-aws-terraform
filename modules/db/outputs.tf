# modules/db/outputs.tf
output "rds_endpoint" {
  description = "RDS endpoint address"
  value       = aws_db_instance.rds.endpoint
  sensitive   = true
}