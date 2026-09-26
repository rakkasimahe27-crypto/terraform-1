variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  
}
variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "mahe"
  
}
variable "subnet1_cidr_block" {
  description = "The CIDR block for the first subnet"
  type        = string
  default     = "10.0.0.0/24"
}
variable "subnet1_name" {
  description = "The name of the first subnet"
  type        = string
  default     = "Mahe-subnet1"

}