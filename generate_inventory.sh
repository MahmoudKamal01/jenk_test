#!/bin/bash

# Get the public IP from terraform
EC2_IP=$(terraform -chdir=terraform output -raw public_ip)

# Create ansible inventory file
cat > inventory.ini <<EOF
[ec2]
ec2-instance ansible_host=${EC2_IP} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/jenk.pem
EOF

echo "Inventory generated with IP: $EC2_IP"
