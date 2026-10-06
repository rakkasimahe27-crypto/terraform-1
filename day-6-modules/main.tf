module "network" {
    source = "./modules/network"
    vpc_cidr = "10.0.0.0/16"
    vpc_name = "my-vpc"
    subnet_cidr = "10.0.1.0/24"
    subnet_az = "us-west-2a"
    subnet_name = "my-subnet"
}
module "instance" {
    source = "./modules/compute"
    subnet_id = module.network.subnet_id
    ami_id = "ami-0d53cc9bd365ad65b"
    instance_type = "t2.micro"
    instance_name = "mahesh-instance"
}
module "instance1" {
    source = "./modules/compute"
    subnet_id = module.network.subnet_id
    ami_id = "ami-0d53cc9bd365ad65b"
    instance_type = "t2.medium"
    instance_name = "mahesh-instance1"
}
module "s3" {
    source = "./modules/s3"
    bucket_name = "mahesh-bucket-88000934567890"
    bucket_acl = "private"
    environment = "dev"
    versioning_status = "Enabled"
}
