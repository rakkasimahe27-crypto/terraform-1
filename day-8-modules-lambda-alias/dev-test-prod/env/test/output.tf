output "privateip" {
  value = [
    module.instance.private_ip,
    module.instance1.private_ip
  ]
}
output "instanceid" {
  value = [
    module.instance.instance_id,
    module.instance1.instance_id
  ]
}