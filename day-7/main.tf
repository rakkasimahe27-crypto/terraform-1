module "network" {
    source = "github.com/rakkasimahe27-crypto/terraform-1/day-6-modules/modules/network"
    vpc_cidr = "192.168.0.0/16"
    vpc_name = "my-vpc"
    subnet_cidr = "192.168.1.0/24"
    subnet_az = "us-west-2a"
    subnet_name = "my-subnet"
}
module "instance" {
    source = "github.com/rakkasimahe27-crypto/terraform-1/day-6-modules/modules/compute"
    subnet_id = module.network.subnet_id
    ami_id = "ami-075d448db8fb256af"
    instance_type = "t2.micro"
    instance_name = "ma-instance"
}
