resource "aws_vpc" "name" {
  cidr_block = var.cidr_block
    tags = {
        Name = var.vpc_name
    }
}
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.name.id
  cidr_block = var.subnet_cidr
  tags = {
    Name = var.subnet_name
  }
}
resource "aws_instance" "web" {
  ami           = "ami-0fef201115eefe936"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  tags = {
    Name = "web-instance"
  }
}
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.name.id

  dynamic "ingress" {
    for_each = [22, 80, 443, 3306]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name-71246"

  tags = {
    Name        = "MyBucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "my_bucket" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.name.id
  cidr_block = var.subnet2_cidr
  availability_zone = "us-east-1a"
  tags = {
    Name = var.subnet2_name
  }
}
resource "aws_subnet" "subnet3" {
  vpc_id     = aws_vpc.name.id
  cidr_block = var.subnet3_cidr
  availability_zone = "us-east-1b"
  tags = {
    Name = var.subnet3_name
  }
}
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.subnet2.id, aws_subnet.subnet3.id]

  tags = {
    Name = "My DB Subnet Group"
  }
}
resource "aws_db_instance" "my_db_instance" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  skip_final_snapshot   = true

  tags = {
    Name = "MyDBInstance"
  }
}
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.name.id

  tags = {
    Name = "MyInternetGateway"
  }
}
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}
resource "aws_route_table_association" "subnet1_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.my_route_table.id
}
resource "aws_route_table_association" "subnet2_association" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.my_route_table.id
}
resource "aws_route_table_association" "subnet3_association" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.my_route_table.id
}
resource "aws_eip" "my_eip" {
  domain = "vpc"

  tags = {
    Name = "MyEIP"
  }
}
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.subnet4.id

  tags = {
    Name = "MyNATGateway"
  }
}
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.name.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
  }
}
resource "aws_route_table_association" "subnet4_private_association" {
  subnet_id      = aws_subnet.subnet4.id
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_subnet" "subnet4" {
  vpc_id     = aws_vpc.name.id
  cidr_block = var.subnet4_cidr
  availability_zone = "us-east-1c"
  tags = {
    Name = var.subnet4_name
  }
}