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
resource "aws_s3_bucket" "name" {
    bucket = "terraform-day-2-88ucket"
}