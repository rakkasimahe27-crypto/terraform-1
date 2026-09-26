resource "aws_vpc" "name" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.vpc_name
  }

}
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.name.id
  cidr_block = var.subnet_cidr
  availability_zone = "us-east-1a"
  tags = {
    Name = "public-subnet"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "my-igw"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.name.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.public.id
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

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.name.id
  cidr_block = var.subnet2_cidr
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-subnet"
  }
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnet1.id
  tags = {
    Name = "my-nat-gateway"
  }
}
resource "aws_eip" "nat" {
  domain = "vpc"

}   
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.name.id
  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
}   
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.private.id
}   
resource "aws_instance" "web" {
  ami           = "ami-0fef201115eefe936"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "web-instance"
  }
}
resource "aws_instance" "app" {
  ami           = "ami-0fef201115eefe936"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "app-instance"
  }
}
resource "aws_instance" "db" {
  ami           = "ami-0fef201115eefe936"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.subnet2.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name = "my-key-pair"
  tags = {
    Name = "db-instance"
  }
}