resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16"
    provider = aws.dev
    tags = {
      "key" = "test"
    }
  
}

resource "aws_s3_bucket" "name" {
    bucket = "ertyucviigh"
    provider = aws.test
  
}
resource "aws_vpc" "secondary" {
  cidr_block = "192.168.0.0/16"
  provider = aws.mah
}