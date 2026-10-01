# Make sure you have your provider configured (e.g., in a providers.tf file)
# provider "aws" {
#   region = "us-east-1"
# }

resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "name" {
  vpc_id            = aws_vpc.name.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_internet_gateway" "name" {
  vpc_id = aws_vpc.name.id

  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.name.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.name.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Allow Jenkins and SSH"
  vpc_id      = aws_vpc.name.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

resource "aws_key_pair" "name" {
  key_name   = "my-key"
  # FIX: Use pathexpand to resolve the '~' home directory alias
  public_key = file(pathexpand("~/.ssh/id_ed25519.pub"))
}

resource "aws_instance" "name" {
  ami                         = "ami-0d53cc9bd365ad65b" # Amazon Linux 2023 AMI
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.name.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.name.key_name

  tags = {
    Name = "jenkins"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install java-21-amazon-corretto -y",
      "sudo dnf install wget -y", # FIX: AL2023 doesn't have wget by default
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key", # FIX: Updated to correct key
      "sudo dnf install jenkins -y",
      "sudo systemctl enable jenkins",
      "sudo systemctl start jenkins",
      "sudo systemctl status jenkins --no-pager"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      # FIX: Use pathexpand to resolve the '~' home directory alias
      private_key = file(pathexpand("~/.ssh/id_ed25519"))
      host        = self.public_ip
    }
  }
}
output "jenkins_url" {
  value       = "http://${aws_instance.name.public_ip}:8080"
  description = "The URL to access the Jenkins UI"
}

output "get_password_command" {
  value       = "ssh -i ~/.ssh/id_ed25519 ec2-user@${aws_instance.name.public_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
  description = "Run this command in your terminal to get the initial admin password"
}