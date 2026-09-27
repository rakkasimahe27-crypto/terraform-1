variable "cidr_block" {
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
variable "subnet3_cidr" {
  type = string
  default = ""
  description = "The CIDR block for the third subnet"
}
variable "subnet3_name" {
  type = string
  default = ""
  description = "The name for the third subnet"
}
variable "db_username" {
  type = string
  default = ""
  description = "The username for the RDS database"
}
variable "db_password" {
  type = string
  default = ""
  description = "The password for the RDS database"
}
variable "subnet4_cidr" {
  type = string
  default = ""
  description = "The CIDR block for the fourth subnet"
}
variable "subnet4_name" {
  type = string
  default = ""
  description = "The name for the fourth subnet"
}