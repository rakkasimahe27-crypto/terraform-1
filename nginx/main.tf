provider "aws" {
  region = "us-west-2"
}

# =========================================================
# VPC
# =========================================================

resource "aws_vpc" "mahe_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "mahe-vpc"
  }
}

# =========================================================
# Internet Gateway
# =========================================================

resource "aws_internet_gateway" "mahe_igw" {
  vpc_id = aws_vpc.mahe_vpc.id

  tags = {
    Name = "mahe-igw"
  }
}

# =========================================================
# Public Subnet 1
# =========================================================

resource "aws_subnet" "mahe_public_subnet_1" {
  vpc_id                  = aws_vpc.mahe_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "mahe-public-subnet-1"
  }
}

# =========================================================
# Public Subnet 2
# =========================================================

resource "aws_subnet" "mahe_public_subnet_2" {
  vpc_id                  = aws_vpc.mahe_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "mahe-public-subnet-2"
  }
}

# =========================================================
# Public Route Table
# =========================================================

resource "aws_route_table" "mahe_public_route" {
  vpc_id = aws_vpc.mahe_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mahe_igw.id
  }

  tags = {
    Name = "mahe-public-route"
  }
}

# =========================================================
# Public Route Association 1
# =========================================================

resource "aws_route_table_association" "mahe_public_route_association_1" {
  route_table_id = aws_route_table.mahe_public_route.id
  subnet_id      = aws_subnet.mahe_public_subnet_1.id
}

# =========================================================
# Public Route Association 2
# =========================================================

resource "aws_route_table_association" "mahe_public_route_association_2" {
  route_table_id = aws_route_table.mahe_public_route.id
  subnet_id      = aws_subnet.mahe_public_subnet_2.id
}

# =========================================================
# Elastic IP for NAT Gateway
# =========================================================

resource "aws_eip" "mahe_nat_eip" {
  domain = "vpc"

  tags = {
    Name = "mahe-nat-eip"
  }
}

# =========================================================
# NAT Gateway
# =========================================================

resource "aws_nat_gateway" "mahe_nat_gateway" {
  allocation_id = aws_eip.mahe_nat_eip.id
  subnet_id     = aws_subnet.mahe_public_subnet_1.id

  depends_on = [
    aws_internet_gateway.mahe_igw
  ]

  tags = {
    Name = "mahe-nat-gateway"
  }
}

# =========================================================
# Private Subnet 1
# =========================================================

resource "aws_subnet" "mahe_private_subnet_1" {
  vpc_id            = aws_vpc.mahe_vpc.id
  availability_zone = "us-west-2a"
  cidr_block        = "10.0.3.0/24"

  tags = {
    Name = "mahe-private-subnet-1"
  }
}

# =========================================================
# Private Subnet 2
# =========================================================

resource "aws_subnet" "mahe_private_subnet_2" {
  vpc_id            = aws_vpc.mahe_vpc.id
  availability_zone = "us-west-2b"
  cidr_block        = "10.0.4.0/24"

  tags = {
    Name = "mahe-private-subnet-2"
  }
}

# =========================================================
# Private Route Table
# =========================================================

resource "aws_route_table" "mahe_private_route" {
  vpc_id = aws_vpc.mahe_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mahe_nat_gateway.id
  }

  tags = {
    Name = "mahe-private-route"
  }
}

# =========================================================
# Private Route Association 1
# =========================================================

resource "aws_route_table_association" "mahe_private_route_association_1" {
  route_table_id = aws_route_table.mahe_private_route.id
  subnet_id      = aws_subnet.mahe_private_subnet_1.id
}

# =========================================================
# Private Route Association 2
# =========================================================

resource "aws_route_table_association" "mahe_private_route_association_2" {
  route_table_id = aws_route_table.mahe_private_route.id
  subnet_id      = aws_subnet.mahe_private_subnet_2.id
}

# =========================================================
# DB Subnet 1
# =========================================================

resource "aws_subnet" "mahe_db_subnet_1" {
  vpc_id            = aws_vpc.mahe_vpc.id
  availability_zone = "us-west-2a"
  cidr_block        = "10.0.5.0/24"

  tags = {
    Name = "mahe-db-subnet-1"
  }
}

# =========================================================
# DB Subnet 2
# =========================================================

resource "aws_subnet" "mahe_db_subnet_2" {
  vpc_id            = aws_vpc.mahe_vpc.id
  availability_zone = "us-west-2b"
  cidr_block        = "10.0.6.0/24"

  tags = {
    Name = "mahe-db-subnet-2"
  }
}

# =========================================================
# Security Group
# =========================================================

resource "aws_security_group" "mahe_ec2_sg" {
  name        = "mahe-ec2-sg"
  description = "Security group for Mahe EC2 instances"
  vpc_id      = aws_vpc.mahe_vpc.id

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins
  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mahe-ec2-sg"
  }
}

# =========================================================
# Frontend EC2
# =========================================================

resource "aws_instance" "mahe_frontend_server" {

  ami           = "ami-0d53cc9bd365ad65b"
  instance_type = "t2.medium"

  subnet_id = aws_subnet.mahe_private_subnet_1.id

  vpc_security_group_ids = [
    aws_security_group.mahe_ec2_sg.id
  ]

  user_data = <<-EOF
              #!/bin/bash

              dnf update -y

              dnf install nginx -y

              systemctl enable nginx
              systemctl start nginx

              echo "<h1>Mahe Frontend Server</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "mahe-frontend-server"
  }
}

# =========================================================
# Backend EC2
# =========================================================

resource "aws_instance" "mahe_backend_server" {

  ami           = "ami-0d53cc9bd365ad65b"
  instance_type = "t3.micro"

  subnet_id = aws_subnet.mahe_private_subnet_2.id

  vpc_security_group_ids = [
    aws_security_group.mahe_ec2_sg.id
  ]

  user_data = <<-EOF
              #!/bin/bash

              dnf update -y

              dnf install nginx -y

              systemctl enable nginx
              systemctl start nginx

              echo "<h1>Mahe Backend Server</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "mahe-backend-server"
  }
}