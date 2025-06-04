#!/bin/bash

set -e

echo "🔧 Step 1: Updating system..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

echo "🐳 Step 2: Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

echo "✅ Docker installed:"
docker --version

echo "🔁 Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "👥 Adding user '$USER' to docker group..."
sudo usermod -aG docker $USER

echo "🧩 Step 3: Installing Docker Compose..."
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | head -1 | sed -E 's/.*"v([^"]+)".*/\1/')
sudo curl -L "https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose || true

echo "✅ Docker Compose installed:"
docker-compose --version

echo "🐝 Step 4: Initializing Docker Swarm..."
sudo docker swarm init || true

echo "🌐 Step 5: Installing Nginx..."
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

echo "✅ Nginx installed and running:"
nginx -v

echo "🎉 All components are successfully installed:"
echo "- Docker"
echo "- Docker Compose"
echo "- Docker Swarm"
echo "- Nginx"
echo "🔄 Please log out and log back in to apply Docker group membership if needed."
