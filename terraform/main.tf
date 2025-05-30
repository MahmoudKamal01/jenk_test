provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-084568db4383264d4" # Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = "jenk"        # Must exist in AWS
  subnet_id     = "subnet-0248e204859587f21"
  
  # Ensure SSH access is available
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "Jenkins-Terraform-Instance"
  }
}

# Security group allowing SSH access
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Warning: In production, restrict this to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Generate Ansible inventory file
resource "local_file" "ansible_inventory" {
  filename = "../ansible/inventory.ini"
  content = <<-EOT
    [webservers]
    ${aws_instance.example.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=../jenk.pem

    [webservers:vars]
    ansible_python_interpreter=/usr/bin/python3
    ansible_ssh_common_args='-o StrictHostKeyChecking=no'
  EOT

  depends_on = [aws_instance.example]
}

output "public_ip" {
  value = aws_instance.example.public_ip
}

output "inventory_location" {
  value = local_file.ansible_inventory.filename
}
