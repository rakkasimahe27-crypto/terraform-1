resource "aws_vpc" "name" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.name.id
  cidr_block = var.subnet_cidr
  availability_zone = var.subnet_az
  tags = {
    Name = var.subnet_name
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.name.id
}
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_security_group" "sg" {
  name        = "my-security-group"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.name.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
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
output "subnet_id" {
  value = aws_subnet.subnet.id
}
output "route_table_id" {
  value = aws_route_table.rt.id
}
output "security_group_id" {
  value = aws_security_group.sg.id
}