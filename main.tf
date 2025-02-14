provider "aws" {
  region = "eu-central-1"  # Région AWS : Frankfurt
}

# Génération d'une clé privée RSA
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Création du Key Pair AWS avec la clé publique
resource "aws_key_pair" "my_key_pair" {
  key_name   = "yvanhousseine-key"
  public_key = tls_private_key.my_key.public_key_openssh
}

# Enregistrement de la clé privée dans un fichier local
resource "local_file" "private_key" {
  filename        = "./yvanhousseine-key.pem"  # Clé privée enregistrée localement
  content         = tls_private_key.my_key.private_key_pem
  file_permission = "0600"
}

# Envoi de la clé privée vers un bucket S3
resource "aws_s3_bucket_object" "private_key_to_s3" {
  bucket  = "hocine-ons"             # Nom du bucket S3
  key     = "ssh/yvanhousseine-key.pem"  # Chemin dans le bucket
  source  = "./yvanhousseine-key.pem"    # Fichier local généré précédemment
  acl     = "private"               # Rend la clé privée accessible uniquement à l’utilisateur AWS
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
