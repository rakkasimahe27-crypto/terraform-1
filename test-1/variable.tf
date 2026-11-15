variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "The CIDR block for subnet 1"
  type        = string
}

variable "subnet_az" {
  description = "The availability zone for subnet 1"
  type        = string
}

variable "subnet_name" {
  description = "The name of subnet 1"
  type        = string
}

variable "subnet2_cidr" {
  description = "The CIDR block for subnet 2"
  type        = string
}

variable "subnet2_az" {
  description = "The availability zone for subnet 2"
  type        = string
}

variable "subnet2_name" {
  description = "The name of subnet 2"
  type        = string
}