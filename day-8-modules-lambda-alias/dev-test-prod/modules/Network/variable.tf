variable "vpc_cidr" {
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
variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = ""
}

variable "subnet_az" {
  description = "The availability zone for the subnet"
  type        = string
  default     = ""
}