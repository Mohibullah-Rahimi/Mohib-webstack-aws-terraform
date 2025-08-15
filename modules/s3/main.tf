# modules/s3/main.tf
# S3 bucket for assets/logs with randomized suffix to avoid name collisions

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "assets" {
  bucket = "${var.project}-assets-${random_id.suffix.hex}"
  acl    = "private"

  tags = {
    Name      = "${var.project}-assets"
    Project   = var.project
    CreatedBy = "Mohibullah-Rahimi"
  }

  force_destroy = true  # WARNING: deletes objects when bucket destroyed. Good for test environments.
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}