resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "name" {
  vpc_id     = aws_vpc.name.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnet1"
  }
}

resource "aws_subnet" "name1" {
  vpc_id     = aws_vpc.name.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "subnet2"
  }
}

resource "aws_internet_gateway" "name" {
  vpc_id = aws_vpc.name.id
  

  tags = {
    Name = "main-igw"
  }
}
resource "aws_route" "dev" {
  route_table_id         = aws_vpc.name.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.name.id
}

resource "aws_route_table" "name" {
  vpc_id = aws_vpc.name.id

  tags = {
    Name = "main-route-table"
  }
}