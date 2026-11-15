resource "aws_vpc" "name" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.vpc_name
  }

}
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.name.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.subnet_az
  tags = {
    Name = var.subnet_name
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
  vpc_id            = aws_vpc.name.id
  cidr_block        = var.subnet2_cidr
  availability_zone = var.subnet2_az
  tags = {
    Name = var.subnet2_name
  }
}
resource "aws_nat_gateway" "nat" {
  subnet_id = aws_subnet.subnet1.id
  allocation_id = aws_eip.nat.id
  tags = {
    Name = "my-nat-gateway"
  }
}
resource "aws_eip" "nat" {
  depends_on = [aws_internet_gateway.igw]
  domain = "vpc"
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.name.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.private.id
}
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  associate_public_ip_address = true
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "Docker-Instance"
  }
}
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.medium"
  associate_public_ip_address = true
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "app-instance"
  }
}
resource "aws_instance" "db" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.subnet1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "db-instance"
  }
}