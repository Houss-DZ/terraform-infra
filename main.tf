provider "aws" {
  region = "eu-central-1"  # Région AWS : Frankfurt
}

resource "aws_instance" "web" {
  ami           = "ami-08c40ec9ead489470"  # Ubuntu 20.04 LTS AMI pour Frankfurt (eu-central-1)
  instance_type = "t2.micro"               # Instance de type t2.micro (éligible au niveau gratuit AWS)

  tags = {
    Name = "YvanHousseine"
  }
}
