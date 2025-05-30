
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-084568db4383264d4" # Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = "jenk.pem"        # Must exist in AWS

  tags = {
    Name = "Jenkins-Terraform-Instance"
  }
}

output "public_ip" {
  value = aws_instance.example.public_ip
}
