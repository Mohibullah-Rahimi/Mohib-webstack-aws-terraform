# modules/vpc/main.tf
# VPC module: VPC, public/private subnets, IGW, NAT GW, route tables, and security groups

data "aws_availability_zones" "available" {}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = "${var.project}-vpc"
    Project   = var.project
    CreatedBy = "Mohibullah-Rahimi"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name      = "${var.project}-igw"
    Project   = var.project
    CreatedBy = "Mohibullah-Rahimi"
  }
}

# Create public and private subnets across az_count AZs
resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name      = "${var.project}-public-${count.index+1}"
    Tier      = "public"
    Project   = var.project
    CreatedBy = "Mohibullah-Rahimi"
  }
}

resource "aws_subnet" "private" {
  count             = var.az_count
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + var.az_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name      = "${var.project}-private-${count.index+1}"
    Tier      = "private"
    Project   = var.project
    CreatedBy = "Mohibullah-Rahimi"
  }
}

# Allocate an Elastic IP and create a single NAT Gateway in first public subnet
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name      = "${var.project}-nat-eip"
    Project   = var.project
    CreatedBy = "Mohibullah-Rahimi"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name      = "${var.project}-natgw"
    Project   = var.project
    CreatedBy = "Mohibullah-Rahimi"
  }
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name      = "${var.project}-public-rt"
    Project   = var.project
    CreatedBy = "Mohibullah-Rahimi"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private route table with NAT
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name      = "${var.project}-private-rt"
    Project   = var.project
    CreatedBy = "Mohibullah-Rahimi"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Security groups: ALB, Web, DB

resource "aws_security_group" "alb" {
  name        = "${var.project}-alb-sg"
  description = "ALB security group - allow HTTP/HTTPS"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project}-alb-sg"
    Project   = var.project
    CreatedBy = "Mohibullah-Rahimi"
  }
}

resource "aws_security_group" "web" {
  name        = "${var.project}-web-sg"
  description = "Web tier security group - allow traffic from ALB"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Optional: allow SSH from your IP for debugging. Replace X.X.X.X/32 below or keep commented.
  # ingress {
  #   description = "SSH from my IP"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["X.X.X.X/32"] # CHANGE_ME: optionally restrict to your IP
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project}-web-sg"
    Project   = var.project
    CreatedBy = "Mohibullah-Rahimi"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.project}-db-sg"
  description = "DB security group - allow MySQL from web tier"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "MySQL from web SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project}-db-sg"
    Project   = var.project
    CreatedBy = "Mohibullah-Rahimi"
  }
}