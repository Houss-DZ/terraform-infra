provider "aws" {
  region = "eu-central-1"  # Région AWS : Frankfurt
}

# Automatisation pour trouver la dernière AMI Ubuntu 20.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical, propriétaire des AMI Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group pour autoriser SSH (port 22) et HTTP (port 80)
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg-"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Autorise l'accès SSH depuis n'importe où
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Autorise le trafic HTTP depuis n'importe où
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Création de l'instance EC2 avec NGINX et Hello World
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "yvanhousseine-key"  # Nom de ta clé SSH
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "HelloWorldServer"
  }

  # Script d'installation pour NGINX et Hello World
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              echo "Hello World from Terraform with NGINX on $(hostname)" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF
}

# Sortie pour afficher l'adresse IP publique de l'instance
output "instance_public_ip" {
  description = "Adresse IP publique de l'instance EC2"
  value       = aws_instance.web.public_ip
}
