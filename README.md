# General Information

A command-and-control (C2) server manageable via Terraform.

Includes:
- The free-tier Ubuntu image
- The free-tier instance type (t2.micro)
- Pre-configured firewall rules (security groups) for communicating with your instance
- SSH keys being auto-generated and preconfigured on instance creation


# Installation

### Installing AWS CLI
```bash
apt install awscli
aws configure
```

### Installing Terraform (Ubuntu)
```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```

# Usage


