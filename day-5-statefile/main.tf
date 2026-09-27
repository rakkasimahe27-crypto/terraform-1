resource "aws_vpc" "name" {
  cidr_block = var.vpc_cidr
    tags = {
        Name = var.vpc_name
    }
}
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.name.id
  cidr_block = var.subnet_cidr
  availability_zone = "us-east-1a"
  tags = {
    Name = var.subnet_name
  }
}
resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.name.id
  cidr_block = var.subnet2_cidr
  availability_zone = "us-east-1b"
  tags = {
    Name = var.subnet2_name
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
resource "aws_instance" "my_instance" {
  ami           = "ami-0fef201115eefe936"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id     = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "MyInstance"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.name.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-puooli-71246"

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
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.subnet1.id

  tags = {
    Name = "MyNATGateway"
  }
}
resource "aws_eip" "my_eip" {
  domain = "vpc"

  tags = {
    Name = "MyEIP"
  }
}
resource "aws_instance" "my_instance2" {
  ami           = "ami-0fef201115eefe936"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id     = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "MyInstance2"
  }
}