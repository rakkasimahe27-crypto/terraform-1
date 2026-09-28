module "network" {
    source = "../../modules/Network"
    vpc_cidr = "10.0.0.0/16"
    vpc_name = "my-vpc"
    subnet_cidr = "10.0.1.0/24"
    subnet_az = "us-west-2a"
    subnet_name = "my-subnet"
}
module "instance" {
    source = "../../modules/Compute"
    subnet_id = module.network.subnet_id
    ami_id = "ami-075d448db8fb256af"
    instance_type = "t3.micro"
    instance_name = "mahesh-instance"
}
module "instance1" {
    source = "../../modules/Compute"
    subnet_id = module.network.subnet_id
    ami_id = "ami-075d448db8fb256af"
    instance_type = "t3.small"
    instance_name = "mahesh-instance1"
}
