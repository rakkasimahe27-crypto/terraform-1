variable "vpc_cidr" {
  type = string
  default = ""
  description = "The CIDR block for the VPC"
  
}
variable "vpc_name" {
  type = string
  default = ""
  description = "The name for the VPC"
}
variable "subnet_cidr" {
  type = string
  default = ""
  description = "The CIDR block for the subnet"
}
variable "subnet_name" {
  type = string
  default = ""
  description = "The name for the subnet"
}
variable "subnet2_cidr" {
  type = string
  default = ""
  description = "The CIDR block for the second subnet"
}
variable "subnet2_name" {
  type = string
  default = ""
  description = "The name for the second subnet"
}