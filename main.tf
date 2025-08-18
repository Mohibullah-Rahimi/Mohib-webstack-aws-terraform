# main.tf - root module wiring
# Create core modules: vpc, web, db, s3

provider "aws" {}

module "vpc" {
  source      = "./modules/vpc"
  project     = var.project_name
  vpc_cidr    = var.vpc_cidr
  aws_region  = var.aws_region
  az_count    = var.az_count
}

module "s3" {
  source     = "./modules/s3"
  project    = var.project_name
  aws_region = var.aws_region
}

module "web" {
  source             = "./modules/web"
  project            = var.project_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  aws_region         = var.aws_region
  instance_type      = var.instance_type
  key_name           = var.key_name
  alb_sg_id          = module.vpc.alb_sg_id
  web_sg_id          = module.vpc.web_sg_id
}

module "db" {
  source        = "./modules/db"
  project       = var.project_name
  db_subnet_ids = module.vpc.private_subnet_ids
  vpc_id        = module.vpc.vpc_id
  db_username   = var.db_username
  db_password   = var.db_password
  db_sg_id      = module.vpc.db_sg_id
  aws_region    = var.aws_region
}