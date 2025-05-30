#!/bin/bash
echo "Running deployment script on $(hostname)"
# Add your commands here
sudo yum update -y
docker --version || echo "Docker not installed"
