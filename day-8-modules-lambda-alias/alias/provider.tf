provider "aws" {
  region = "us-east-1"
  profile = "test-profile"
  alias = "dev"
  
}

provider "aws" {
    region = "us-west-2"
    profile = "test-profile"  #if different account profile change here 
    alias = "test"
  
}
provider "aws" {
    region = "us-west-2"
    alias = "mah"
    profile = "test-profile"
  
}