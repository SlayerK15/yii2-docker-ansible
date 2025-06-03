# Yii2 Docker Development Environment

A complete Docker-based development environment for Yii2 applications with nginx, PHP-FPM, and MySQL.

## Project Structure

```
yii2-docker-ansible/
├── docker/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── docker-entrypoint.sh
├── nginx-conf/
│   └── yii2-app.conf
├── yii2_sample_app/
│   ├── web/
│   ├── config/
│   ├── vendor/
│   └── ... (Yii2 application files)
└── README.md
```

## Prerequisites

### System Requirements
- Ubuntu 20.04+ (or similar Linux distribution)
- At least 2GB RAM and 10GB free disk space
- Internet connection for downloading packages

### Check Current Versions
```bash
# Check if already installed
docker --version
docker-compose --version
nginx -v
git --version
```

## Installation Guide

### 1. Install Docker and Docker Compose

**Method 1: Official Docker Installation (Recommended)**
```bash
# Remove any old Docker installations
sudo apt-get remove docker docker-engine docker.io containerd runc

# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose (v2)
sudo apt-get install -y docker-compose-plugin

# Add current user to docker group (to run docker without sudo)
sudo usermod -aG docker $USER

# Log out and back in, or run:
newgrp docker

# Verify installation
docker --version
docker compose version
```

**Method 2: Quick Installation (Alternative)**
```bash
# Install Docker using convenience script
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### 2. Install Nginx

```bash
# Update package list
sudo apt-get update

# Install Nginx
sudo apt-get install -y nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Check status
sudo systemctl status nginx

# Verify installation
nginx -v

# Test basic functionality
curl -I http://localhost
# Should return: HTTP/1.1 200 OK
```

### 3. Install Additional Dependencies

```bash
# Install Git (if not already installed)
sudo apt-get install -y git

# Install useful tools for development
sudo apt-get install -y \
    curl \
    wget \
    unzip \
    vim \
    htop

# Optional: Install PHP and Composer on host (for local development)
sudo apt-get install -y php8.1-cli php8.1-xml php8.1-mbstring
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

### 4. Verify All Dependencies

```bash
# Check Docker
docker run hello-world

# Check Docker Compose
docker compose version

# Check Nginx
sudo nginx -t

# Check Git
git --version

# Check system resources
free -h
df -h
```

### 5. Get the Yii2 Application

**Option A: Clone existing project**
```bash
git clone <your-repo-url>
cd yii2-docker-ansible
```

**Option B: Create new Yii2 project**
```bash
# Create project directory
mkdir yii2-docker-ansible
cd yii2-docker-ansible

# Download Yii2 Basic Template
composer create-project --prefer-dist yiisoft/yii2-app-basic yii2_sample_app

# Or download manually
wget https://github.com/yiisoft/yii2-app-basic/archive/master.zip
unzip master.zip
mv yii2-app-basic-master yii2_sample_app
rm master.zip

# Create docker directory
mkdir docker nginx-conf
```

## Quick Start

```bash
# Navigate to project directory
cd yii2-docker-ansible

# Set up nginx configuration
sudo cp nginx-conf/yii2-app.conf /etc/nginx/conf.d/
sudo nginx -t
sudo systemctl reload nginx

# Fix permissions
sudo chown -R $USER:$USER yii2_sample_app/
chmod 755 yii2_sample_app/

# Build and start containers
docker-compose build --no-cache
docker-compose up -d

# Visit your application
open http://localhost
```

## Problems Encountered & Solutions

### 1. Nginx Version Issue: Missing sites-available/sites-enabled

**Problem:**
Modern nginx installations (especially on newer Ubuntu versions) don't include `sites-available` and `sites-enabled` directories by default. They use a simplified `conf.d` directory structure instead.

**Symptoms:**
```bash
ls /etc/nginx/
# Only shows: conf.d/, nginx.conf, modules-enabled/, etc.
# Missing: sites-available/, sites-enabled/
```

**Root Cause:**
Nginx packaging has evolved. The `sites-available`/`sites-enabled` pattern was a Debian/Ubuntu convention, but newer installations use the simpler `conf.d` approach where any `.conf` file is automatically loaded.

**Solution:**
Place configuration files directly in `/etc/nginx/conf.d/` instead of the traditional sites structure:

```bash
# Instead of:
# sudo ln -s /etc/nginx/sites-available/yii2.conf /etc/nginx/sites-enabled/

# Use:
sudo cp nginx-conf/yii2-app.conf /etc/nginx/conf.d/
sudo nginx -t
sudo systemctl reload nginx
```

**Configuration File (nginx-conf/yii2-app.conf):**
```nginx
server {
    listen 80;
    server_name localhost;
    root /home/kanav/yii2-docker-ansible/yii2_sample_app/web;
    index index.php index.html;
    
    location / {
        try_files $uri $uri/ /index.php$is_args$args;
    }
    
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME /var/www/yii2_sample_app/web$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT /var/www/yii2_sample_app/web;
    }
}
```

### 2. Permission Issues with Docker Volumes

**Problem:**
Container couldn't create the `vendor` directory or install Composer dependencies due to permission mismatches between host and container users.

**Symptoms:**
```bash
In Filesystem.php line 261:
/var/www/yii2_sample_app/vendor does not exist and could not be created:
```

**Root Cause:**
Docker volumes maintain host file ownership, but the container's `www-data` user (UID 33) couldn't write to directories owned by the host user (UID 1000).

**Solution:**
Modified the Dockerfile to align container user UID with host user UID:

```dockerfile
# Create www-data user with same UID as host user (1000)
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

# Create directories and set permissions as root (before switching to www-data)
RUN mkdir -p /var/www/yii2_sample_app/runtime \
             /var/www/yii2_sample_app/web/assets \
             /var/www/yii2_sample_app/vendor \
    && chown -R www-data:www-data /var/www

# Switch to www-data user
USER www-data
```

**Host-side permissions fix:**
```bash
# Fix ownership on host
sudo chown -R $USER:$USER yii2_sample_app/
chmod 755 yii2_sample_app/

# Make runtime directories writable
chmod -R 777 yii2_sample_app/runtime
chmod -R 777 yii2_sample_app/web/assets
```

### 3. File Not Found Issue (404 Errors)

**Problem:**
Nginx could reach PHP-FPM but returned 404 errors because of incorrect path mapping between host and container.

**Symptoms:**
```bash
curl -I http://localhost/
# HTTP/1.1 404 Not Found

# In PHP-FPM logs:
172.18.0.1 - "GET /index.php" 404
```

**Root Cause:**
Path mismatch between nginx (running on host) and PHP-FPM (running in container):
- **Nginx** looks for files at: `/home/kanav/yii2-docker-ansible/yii2_sample_app/web/`
- **PHP-FPM** expects files at: `/var/www/yii2_sample_app/web/`

**Solution:**
Configure nginx to map host paths to container paths via FastCGI parameters:

```nginx
location ~ \.php$ {
    try_files $uri =404;
    fastcgi_pass 127.0.0.1:9000;
    fastcgi_index index.php;
    include fastcgi_params;
    
    # CRITICAL: Map host path to container path
    fastcgi_param SCRIPT_FILENAME /var/www/yii2_sample_app/web$fastcgi_script_name;
    fastcgi_param DOCUMENT_ROOT /var/www/yii2_sample_app/web;
}
```

**Verification:**
```bash
# Test if files are accessible in both environments
ls -la ~/yii2-docker-ansible/yii2_sample_app/web/index.php  # Host
docker exec -it yii2-php ls -la /var/www/yii2_sample_app/web/index.php  # Container
```

### 4. Dockerfile Modifications for Permission Handling

**Problem:**
Initial Dockerfile created directories with root ownership, causing permission conflicts when the container switched to `www-data` user.

**Original Approach (Problematic):**
```dockerfile
# This created directories as root, then switched to www-data
# causing permission issues
RUN mkdir -p /var/www/yii2_sample_app
USER www-data
```

**Improved Solution:**
```dockerfile
FROM php:8.1-fpm

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev libzip-dev \
    zip unzip libicu-dev libfreetype6-dev libjpeg62-turbo-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql mbstring exif pcntl bcmath gd zip intl opcache \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/yii2_sample_app

# Copy entrypoint script and make it executable
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# CRITICAL: Align container user UID with host user UID
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

# Create directories and set proper ownership BEFORE switching users
RUN mkdir -p /var/www/yii2_sample_app/runtime \
             /var/www/yii2_sample_app/web/assets \
             /var/www/yii2_sample_app/vendor \
    && chown -R www-data:www-data /var/www

# Switch to www-data user
USER www-data

EXPOSE 9000
ENTRYPOINT ["docker-entrypoint.sh"]
```

### 5. Migration from Dockerfile Commands to Entrypoint Script

**Problem:**
Running Composer install and other setup tasks in the Dockerfile caused issues with volume mounts and made the container less flexible.

**Why Dockerfile Commands Were Problematic:**
1. **Build-time vs Runtime**: Dockerfile commands run at build time, but volumes are mounted at runtime
2. **Caching Issues**: Changes to application code required rebuilding entire image
3. **Permission Conflicts**: Commands ran as different users at different stages

**Solution: Entrypoint Script Approach**

**docker-entrypoint.sh:**
```bash
#!/bin/bash
set -e

APP_DIR="/var/www/yii2_sample_app"

echo "Starting PHP-FPM container setup..."

# Configure git safely (avoid permission errors)
if [ -w "$HOME" ]; then
    git config --global --add safe.directory "$APP_DIR" 2>/dev/null || echo "Git config skipped"
fi

# Check write permissions
if [ ! -w "$APP_DIR" ]; then
    echo "Warning: No write permission to $APP_DIR"
    echo "Please fix permissions on host: sudo chown -R \$USER:\$USER yii2_sample_app/"
    exit 1
fi

# Install dependencies (runtime, after volume mount)
if [ ! -d "$APP_DIR/vendor" ] || [ ! -f "$APP_DIR/vendor/yiisoft/yii2-debug/composer.json" ]; then
    echo "Installing/updating Composer dependencies (including dev)..."
    cd "$APP_DIR"
    
    if [ ! -d "vendor" ]; then
        mkdir -p vendor || {
            echo "Failed to create vendor directory. Permission issue?"
            exit 1
        }
    fi
    
    # Remove incomplete vendor directory
    if [ -d "vendor" ] && [ ! -f "vendor/yiisoft/yii2-debug/composer.json" ]; then
        rm -rf vendor
    fi
    
    composer install --optimize-autoloader --no-interaction
else
    echo "Dev dependencies already installed."
fi

# Create and set permissions for runtime directories
mkdir -p "$APP_DIR/runtime" "$APP_DIR/web/assets" || true
chmod -R 755 "$APP_DIR/runtime" "$APP_DIR/web/assets" 2>/dev/null || true

echo "PHP-FPM setup complete. Starting PHP-FPM..."

# Start PHP-FPM
exec php-fpm
```

**Benefits of Entrypoint Approach:**
1. **Runtime Execution**: Commands run after volumes are mounted
2. **Flexibility**: Container adapts to current application state
3. **Better Error Handling**: Can detect and report permission issues
4. **Development Friendly**: No need to rebuild for dependency changes

## Environment Details

**Host System Requirements:**
- Ubuntu 20.04+ (or similar Linux distribution)
- Docker 20.10+ and Docker Compose 2.0+
- Nginx 1.18+
- Git 2.25+
- At least 2GB RAM and 10GB free disk space

**Container Stack:**
- **PHP**: 8.1-FPM with extensions (pdo_mysql, mbstring, gd, zip, intl, etc.)
- **Database**: MySQL 8.0
- **Application**: Yii2 Basic Template with debug and gii modules

**Port Configuration:**
- **Web Server**: `http://localhost:80` (nginx)
- **PHP-FPM**: `127.0.0.1:9000` (container)
- **MySQL**: `127.0.0.1:3306` (container)

## Common Installation Issues

### Docker Permission Denied
```bash
# If you get permission denied errors
sudo usermod -aG docker $USER
newgrp docker

# Or logout and login again
logout
# Then login again
```

### Nginx Already Running
```bash
# If port 80 is already in use
sudo systemctl stop apache2  # Stop Apache if running
sudo netstat -tlnp | grep :80  # Check what's using port 80

# If another nginx is running
sudo killall nginx
sudo systemctl start nginx
```

### Docker Compose Command Not Found
```bash
# If docker-compose command doesn't work, try:
docker compose --version

# For older systems, install docker-compose separately:
sudo pip install docker-compose
```

### Insufficient Disk Space
```bash
# Clean up Docker resources
docker system prune -a
docker volume prune

# Check available space
df -h
```

## Development Workflow

**Daily Development:**
```bash
# Start environment
docker-compose up -d

# View logs
docker-compose logs -f app

# Access container shell
docker exec -it yii2-php bash

# Run Yii console commands
docker exec -it yii2-php php yii help

# Stop environment
docker-compose down
```

**Dependency Management:**
```bash
# Add new Composer package
docker exec -it yii2-php composer require package/name

# Update dependencies
docker exec -it yii2-php composer update
```

**Database Operations:**
```bash
# Access MySQL container
docker exec -it yii2-db mysql -u yii2user -pyii2password yii2db

# Run migrations
docker exec -it yii2-php php yii migrate
```

## Troubleshooting

### Dependency Issues

**Docker Installation Problems:**
```bash
# If Docker daemon isn't running
sudo systemctl start docker
sudo systemctl enable docker

# If permission denied
sudo usermod -aG docker $USER
newgrp docker

# If docker command not found
# Reinstall Docker following the official guide above
```

**Nginx Issues:**
```bash
# If nginx fails to start
sudo systemctl status nginx
sudo journalctl -u nginx

# Check configuration syntax
sudo nginx -t

# If port 80 is busy
sudo netstat -tlnp | grep :80
sudo systemctl stop apache2  # If Apache is running
```

**Port Conflicts:**
```bash
# Check what's using required ports
sudo netstat -tlnp | grep :80   # Web server
sudo netstat -tlnp | grep :9000 # PHP-FPM
sudo netstat -tlnp | grep :3306 # MySQL

# Kill processes if needed
sudo kill -9 <PID>
```

### Container Issues

**Container Won't Start:**
```bash
# Check container status
docker-compose ps

# View detailed logs
docker-compose logs app

# Check for permission issues
ls -la yii2_sample_app/
```

**Permission Errors:**
```bash
# Fix host permissions
sudo chown -R $USER:$USER yii2_sample_app/
chmod 755 yii2_sample_app/

# Rebuild container
docker-compose build --no-cache
docker-compose up -d
```

**404 Errors:**
```bash
# Check nginx configuration
sudo nginx -t

# Verify file paths
ls -la ~/yii2-docker-ansible/yii2_sample_app/web/index.php
docker exec -it yii2-php ls -la /var/www/yii2_sample_app/web/index.php

# Check nginx error logs
sudo tail -f /var/log/nginx/yii2-error.log
```

## Key Learnings

1. **Modern Nginx**: Use `conf.d/` instead of `sites-available`/`sites-enabled`
2. **Docker Permissions**: Align container user UID with host user UID (1000)
3. **Path Mapping**: Configure FastCGI parameters to map host paths to container paths
4. **Runtime vs Build-time**: Use entrypoint scripts for volume-dependent operations
5. **Error Handling**: Implement proper permission checks and error reporting

This setup provides a robust, development-friendly environment that handles the most common Docker + PHP + Nginx integration challenges.