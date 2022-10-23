## General Information

One-button-push infrastructure solutions manageable via Terraform.

`redsmoke` consist of terraform scripts for deploying various machines used within an infrastructure you're looking for on a pentest or red team engagement.

`redsmoke` includes the following units:

- `generic-unit`:
  - A free-tier Kali image
  - A free-tier instance type (t2.micro)
  - Pre-configured firewall rules: 
    - 22/tcp from everywhere
    - 80/tcp from everywhere
    - 443/tcp from everywhere
  - SSH keys auto-generated per instance creation

- `vpn-unit`:
  - A free-tier Kali image
  - A free-tier instance type (t2.micro)
  - Pre-configured firewall rules:
    - 22/tcp from everywhere
    - 1194/udp from everywhere


## Installation

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

### Cloning redsmoke
```bash
git clone https://github.com/cyberhexe/redsmoke
cd redsmoke
```

## Usage

### Creating the infrastructure 


#### generic-unit

Deploying a generic cloud unit:

```bash
cd generic-unit
terraform init
terraform apply -auto-approve
```

Terminating a generic cloud unit:

```bash
cd generic-unit
terraform destroy -auto-approve
```

#### vpn-unit

Deploying a VPN unit:

```bash
cd vpn-unit
terraform init
terraform apply -auto-approve
```

Terminating a VPN unit:

```bash
cd vpn-unit
terraform destroy -auto-approve
```