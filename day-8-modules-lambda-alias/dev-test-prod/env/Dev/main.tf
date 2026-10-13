# Fetch latest Amazon Linux 2023 AMI in root module
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# =========================================================
# NETWORK (1 VPC with 2 Subnets across 2 AZs)
# =========================================================

module "network" {
  source = "../../modules/Network"

  vpc_cidr = "10.0.0.0/16"
  vpc_name = "my-vpc"

  # Subnet 1
  subnet_cidr = "10.0.1.0/24"
  subnet_az   = "us-west-2a"
  subnet_name = "my-subnet-1"

}

# =========================================================
# JENKINS SERVER
# =========================================================

module "jenkins_master" {
  source = "../../modules/Compute"

  subnet_id          = module.network.subnet_id
  security_group_ids = [module.network.security_group_id]

  instance_type = "t2.medium"
  instance_name = "jenkins"
  key_name      = "jenkins"
  ami_id        = data.aws_ami.amazon_linux.id
}

# =========================================================
# SLAVE 1 (Placed in Subnet 1)
# =========================================================

module "slave_1" {
  source = "../../modules/Compute"

  subnet_id          = module.network.subnet_id
  security_group_ids = [module.network.security_group_id]

  instance_type = "t2.medium"
  instance_name = "slave-1"
  key_name      = "jenkins"
  ami_id        = data.aws_ami.amazon_linux.id
}

# =========================================================
# SLAVE 2 (Optional: Placed in Subnet 2 or Subnet 1)
# =========================================================

module "slave_2" {
  source = "../../modules/Compute"

  subnet_id          = module.network.subnet_2_id # Or module.network.subnet_id
  security_group_ids = [module.network.security_group_id]

  instance_type = "t2.medium"
  instance_name = "slave-2"
  key_name      = "jenkins"
  ami_id        = data.aws_ami.amazon_linux.id
}