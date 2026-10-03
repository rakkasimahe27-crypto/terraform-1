resource "aws_instance" "name" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = var.security_group_ids

  key_name = var.key_name

  user_data = <<-EOF
    #!/bin/bash

    # Update packages
    dnf update -y

    # Install Java 21
    dnf install -y java-21-amazon-corretto-devel

    # Verify Java
    java -version > /var/log/java-install.log 2>&1
  EOF

  tags = {
    Name = var.instance_name
  }
}