output "privateip" {
  value = module.instance.private_ip
  
}
output "instance_ip" {
    value = module.instance.instance_id
  
}