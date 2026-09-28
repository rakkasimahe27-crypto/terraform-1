output "private_ip" {
  value = aws_instance.name.private_ip
}

output "instance_id" {
  value = aws_instance.name.id
}