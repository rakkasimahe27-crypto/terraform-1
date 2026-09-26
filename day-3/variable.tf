variable "cidr_block" {
description = "The CIDR block for the VPC"
  type        = string
  default     = ""  
}
variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = ""
}
variable "subnet_cidr" {
  description = "The CIDR block for the subnet"
  type        = string
  default     = ""
}
variable "subnet2_cidr" {
  description = "The CIDR block for the second subnet"
  type        = string
  default     = ""
}