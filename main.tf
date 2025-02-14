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

# Création de l'instance EC2 avec NGINX et Hello World
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "ma clé ssh"  # Remplace par le nom de ta clé SSH existante

  tags = {
    Name = "YvanHousseine"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              echo "Hello World from Terraform with NGINX on $(hostname)" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF
}

# Sortie pour afficher l'adresse publique de l'instance
output "instance_public_ip" {
  description = "Adresse IP publique de l'instance EC2"
  value       = aws_instance.web.public_ip
}

