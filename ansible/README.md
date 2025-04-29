# Yii2 Application Deployment with Docker and Swarm

This Ansible playbook automates the deployment of a Yii2 application using Docker and Docker Swarm.

## Prerequisites

- Ubuntu server (18.04 or later)
- Ansible 2.9+
- SSH access to the target server

## Directory Structure

```
ansible/
├── group_vars/          # Group variables
│   └── all.yml          # Variables for all hosts
├── hosts                # Inventory file
├── inventory            # Alternative inventory file
├── main.yml             # Main playbook
├── tasks/               # Task definitions
│   ├── 01-common-setup.yml
│   ├── 02-docker-setup.yml
│   ├── 03-swarm-setup.yml
│   ├── 04-container-setup.yml
│   ├── 05-nginx-setup.yml
│   ├── 06-deployment.yml
│   └── 07-verification.yml
├── templates/           # Jinja2 templates
│   └── docker-compose.yml.j2
└── vars/                # Variables
    └── main.yml         # Main variables file
```

## Usage

1. Ensure you have configured your SSH keys for the target server.
2. Update the inventory file with your server details if needed.
3. Review and update `vars/main.yml` with your configuration values.
4. Run the playbook:

```bash
# Using the inventory file
ansible-playbook -i inventory main.yml

# OR for local deployment
ansible-playbook main.yml
```

## What This Playbook Does

1. Installs common dependencies
2. Sets up Docker and Docker Compose
3. Initializes Docker Swarm
4. Pulls the pre-built Yii2 application Docker image
5. Configures Nginx as a reverse proxy
6. Deploys the application stack to Docker Swarm
7. Verifies the deployment

## Docker Image

This playbook uses the pre-built Docker image `slayerop15/yii2-app:latest` from Docker Hub. 