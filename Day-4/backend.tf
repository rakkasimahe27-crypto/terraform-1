terraform {
  backend "s3" {
    bucket = "my-unique-bucket-name-71246"
    key    = "terraform-statefile/terraform.tfstate"
    region = "us-east-1"
  }
}