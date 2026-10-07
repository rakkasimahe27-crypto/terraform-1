resource "aws_vpc" "name" {
    cidr_block = var.cidr_block
    tags = {
        Name = var.vpc_name
    }
  
}
resource "aws_subnet" "subnet1" {
    vpc_id = aws_vpc.name.id
    cidr_block = var.subnet1_cidr_block
    availability_zone = "us-west-2a"
    tags = {
        Name = var.subnet1_name
    }
}
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.name.id
    tags = {
        Name = "vpc-igw"
    }
}
resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.name.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "vpc-rt"
    }
}
resource "aws_route_table_association" "rta" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.rt.id
}
resource "aws_security_group" "sg" {
    name = "terraform-day-2-sg"
    description = "Allow SSH and HTTP"
    vpc_id = aws_vpc.name.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_instance" "web" {
    ami = "ami-0d27e0fb3bac4d724"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.subnet1.id
    vpc_security_group_ids = [aws_security_group.sg.id]
    tags = {
        Name = "terraform-day-2-instance"
    }
}
