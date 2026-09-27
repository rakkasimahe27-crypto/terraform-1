terraform {
  backend "s3" {
    bucket = "my-unique-bucket-name-71246"
    key    = "terraform-statefile/terraform.tfstate"
    region = "us-east-1"
   # lock_file = "terraform-statefile/terraform.tfstate.lock"
    #dynamodb_table = "terraform-statefile-locks" #the name of the DynamoDB table for state locking
  }
}