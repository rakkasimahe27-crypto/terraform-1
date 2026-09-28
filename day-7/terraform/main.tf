module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  name = "moga"
  cidr = "192.0.0.0/16"

  # Declare availability zones and subnets directly in the VPC module
  azs             = ["us-west-2a"]
  private_subnets = ["192.0.1.0/24"]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}