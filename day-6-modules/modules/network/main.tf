resource "aws_vpc" "name" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.name.id
  cidr_block = var.subnet_cidr
  availability_zone = var.subnet_az
  tags = {
    Name = var.subnet_name
  }
}
output "subnet_id" {
  value = aws_subnet.subnet1.id
}