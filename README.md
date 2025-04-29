# Yii2 Docker Swarm Deployment

This project demonstrates deploying a Yii2 PHP application using Docker Swarm and Nginx (host-based reverse proxy) on an AWS EC2 instance. Setup is automated using Ansible and deployed using GitHub Actions CI/CD.

## Project Structure

- `ansible/` - Ansible playbooks for automated infrastructure setup
- `docker/` - Docker configuration (Dockerfile, docker-compose.yml, Nginx config)
- `yii2_sample_app/` - Sample Yii2 PHP application
- `.github/workflows/` - GitHub Actions CI/CD pipeline

## Architecture

1. **Application**: Yii2 PHP framework containerized with Nginx and PHP-FPM
2. **Deployment**: Docker Swarm for container orchestration
3. **Proxy**: Nginx on the host as a reverse proxy to Docker containers
4. **CI/CD**: GitHub Actions for automated building and deployment
5. **Automation**: Ansible for infrastructure setup

## Prerequisites

- AWS EC2 instance running Ubuntu (recommended t2.micro or larger)
- Docker and Docker Compose installed on the server
- GitHub account for CI/CD
- Docker Hub account (for storing container images)

## Setup Instructions

### Infrastructure Setup with Ansible

1. Set up your EC2 instance and ensure it's accessible via SSH
2. Update the Ansible inventory with your EC2 instance details
3. Run the Ansible playbook to set up the infrastructure:

```bash
cd ansible
ansible-playbook -i inventory main.yml
```

The playbook will:
- Install Docker, Docker Compose
- Install Nginx and configure it as a reverse proxy
- Initialize Docker Swarm
- Set up the application environment

### CI/CD Setup

1. Fork this repository to your GitHub account
2. Add the following secrets to your GitHub repository:
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub password
   - `SSH_PRIVATE_KEY`: SSH private key for EC2 access
   - `SSH_KNOWN_HOSTS`: SSH known hosts for your EC2 instance
   - `SSH_USER`: SSH username (usually 'ubuntu' for Ubuntu instances)
   - `SSH_HOST`: Your EC2 instance public IP or DNS name

3. Push changes to the main branch to trigger the CI/CD pipeline

## Manual Deployment

If you prefer to deploy manually:

1. Build the Docker image:
```bash
cd docker
docker build -t yourusername/yii2-app:latest .
```

2. Push the image to Docker Hub:
```bash
docker push yourusername/yii2-app:latest
```

3. Deploy to Docker Swarm:
```bash
docker stack deploy -c docker-stack.yml --prune yii2-app
```

## Testing the Deployment

After deployment, you can access:

- Yii2 Application: http://{your-ec2-ip}/
- PHP Info page: http://{your-ec2-ip}/index.php?r=site/phpinfo

## Health Checks

The deployment includes health checks:
- Nginx health: http://{your-ec2-ip}/health
- Docker container health is monitored by Docker Swarm

## Assumptions

- The EC2 instance has a public IP address
- Security groups allow traffic on ports 22 (SSH), 80 (HTTP), and 9000 (Docker)
- You have appropriate permissions for Docker Hub and AWS resources

## Rollback Procedure

The CI/CD pipeline includes automatic rollback on failure. For manual rollback:

```bash
docker service update --rollback yii2-app_app
```

## Monitoring

For basic monitoring, you can:
- View Docker service status: `docker service ls`
- View container logs: `docker service logs yii2-app_app`
- Check Nginx logs: `/var/log/nginx/access.log` and `/var/log/nginx/error.log`

## License

This project is licensed under the MIT License - see the LICENSE file for details. 