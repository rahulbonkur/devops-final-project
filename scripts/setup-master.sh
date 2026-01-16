#!/bin/bash
# Complete setup script for Jenkins Master VM
# Run this on a fresh Ubuntu 22.04 instance

set -e

echo "========================================="
echo "DevOps Project - Master VM Setup"
echo "========================================="

# Update system
echo "→ Updating system..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install basic tools
echo "→ Installing basic tools..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Install Java (required for Jenkins)
echo "→ Installing Java..."
sudo apt-get install -y openjdk-17-jdk

# Install Jenkins
echo "→ Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y jenkins

# Start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Install Docker
echo "→ Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add Jenkins user to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Install AWS CLI
echo "→ Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

# Install Terraform
echo "→ Installing Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update -y
sudo apt-get install -y terraform

# Install Ansible
echo "→ Installing Ansible..."
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible

# Install Python and pip
echo "→ Installing Python..."
sudo apt-get install -y python3 python3-pip python3-venv

# Install additional Python packages
pip3 install --user boto3 botocore

# Configure Git
echo "→ Configuring Git..."
git config --global user.name "Jenkins"
git config --global user.email "jenkins@localhost"

# Create directories
echo "→ Creating directories..."
mkdir -p ~/projects
mkdir -p ~/.ssh

# Set proper permissions
chmod 700 ~/.ssh

# Display Jenkins initial password
echo ""
echo "========================================="
echo "✅ Setup Complete!"
echo "========================================="
echo ""
echo "Jenkins URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo ""
echo "Initial Jenkins password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword || echo "Jenkins not ready yet. Wait 2 minutes and run: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo ""
echo "Next steps:"
echo "1. Configure AWS credentials: aws configure"
echo "2. Generate or import SSH key for EC2 instances"
echo "3. Clone your project repository"
echo "4. Navigate to Jenkins and complete setup"
echo ""
echo "Installed versions:"
echo "- Java: $(java -version 2>&1 | head -n 1)"
echo "- Jenkins: $(jenkins --version 2>/dev/null || echo 'Check at Jenkins URL')"
echo "- Docker: $(docker --version)"
echo "- Terraform: $(terraform version | head -n 1)"
echo "- Ansible: $(ansible --version | head -n 1)"
echo "- AWS CLI: $(aws --version)"
echo "- Python: $(python3 --version)"
echo ""
echo "========================================="
