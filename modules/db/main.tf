# modules/db/main.tf
resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.project}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name      = "${var.project}-db-subnet-group"
    Project   = var.project
    CreatedBy = "Mohibullah-Rahimi"
  }
}

resource "aws_db_instance" "rds" {
  identifier              = "${var.project}-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "appdb"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids  = [var.db_sg_id]
  publicly_accessible     = false
  skip_final_snapshot     = true   # For dev only. Change for production!
  multi_az                = false

  tags = {
    Name      = "${var.project}-db"
    Project   = var.project
    CreatedBy = "Mohibullah-Rahimi"
  }
}