# =========================================================
# NETWORK
# =========================================================

module "network" {
  source = "../../modules/Network"

  vpc_cidr    = "10.0.0.0/16"
  vpc_name    = "my-vpc"
  subnet_cidr = "10.0.1.0/24"
  subnet_az   = "us-west-2a"
  subnet_name = "my-subnet"
}


# =========================================================
# JENKINS SERVER
# =========================================================

module "instance" {
  source = "../../modules/Compute"

  subnet_id          = module.network.subnet_id
  security_group_ids = [module.network.security_group_id]

  ami_id        = "ami-0d53cc9bd365ad65b"
  instance_type = "t2.medium"
  instance_name = "jenkins"

  key_name = "jenkins"
}


# =========================================================
# SLAVE 1
# =========================================================

module "instance1" {
  source = "../../modules/Compute"

  subnet_id          = module.network.subnet_id
  security_group_ids = [module.network.security_group_id]

  ami_id        = "ami-0d53cc9bd365ad65b"
  instance_type = "t2.medium"
  instance_name = "slave-1"

  key_name = "jenkins"
}


# =========================================================
# SLAVE 2
# =========================================================

module "instance2" {
  source = "../../modules/Compute"

  subnet_id          = module.network.subnet_id
  security_group_ids = [module.network.security_group_id]

  ami_id        = "ami-0d53cc9bd365ad65b"
  instance_type = "t2.medium"
  instance_name = "slave-2"

  key_name = "jenkins"
}