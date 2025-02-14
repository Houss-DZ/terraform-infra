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

# Création de l'instance EC2 avec l'AMI la plus récente
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id  # Utilisation de l'AMI trouvée automatiquement
  instance_type = "t2.micro"              # Type d'instance (éligible au niveau gratuit AWS)

  tags = {
    Name = "YvanHousseine"
  }
}

