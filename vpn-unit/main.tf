#########################################
### GENERAL SETTINGS
#########################################

terraform {
  required_version = ">= 0.14.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}
provider "aws" {
  profile = "default"
  region  = var.redsmoke_region
}

#########################################
### SSH KEYS
#########################################



resource "tls_private_key" "redsmoke_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "redsmoke_key_pair" {
  key_name   = var.redsmoke_key_name
  public_key = tls_private_key.redsmoke_ssh_key.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      echo "${tls_private_key.redsmoke_ssh_key.private_key_pem}" > ./"${var.redsmoke_key_name}".pem
      chmod 400 ./'${var.redsmoke_key_name}'.pem
    EOT
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ./${self.key_name}.pem"
  }
}

#########################################
### SECURITY GROUPS
#########################################

resource "aws_security_group" "redsmoke_security" {
  ingress {
    description      = "SSH From Everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "OpenVPN From Everywhere"
    from_port        = 1194
    to_port          = 1194
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  tags = {
    Name = "redsmoke_vpn_unit_sg"
  }
}

#########################################
### EC2 CONFIGURATION
#########################################

resource "aws_instance" "redsmoke_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.redsmoke_security.id]
  key_name               = aws_key_pair.redsmoke_key_pair.key_name

  tags = {
    Name = var.instance_name
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file("${var.redsmoke_key_name}.pem")
    host        = aws_instance.redsmoke_server.public_ip
    timeout     = "2m"
  }
  provisioner "file" {
    source      = "scripts/1-initial-setup.sh"
    destination = "/tmp/1-initial-setup.sh"
  }
  provisioner "file" {
    source      = "scripts/2-openvpn-install.sh"
    destination = "/tmp/2-openvpn-install.sh"
  }
  provisioner "file" {
    source      = "scripts/docker-compose.yml"
    destination = "/tmp/docker-compose.yml"
  }
  provisioner "remote-exec" {
    inline = [
      "/usr/bin/bash /tmp/1-initial-setup.sh",
      "/usr/bin/sudo /usr/bin/bash /tmp/2-openvpn-install.sh ${var.vpn_user}",
    ]
  }
  provisioner "remote-exec" {
    inline = ["sudo hostnamectl set-hostname vpn-unit"]
  }
}

output "connect_cmd" {
  description = "The public IP for SSH access"
  value       = "SSH service available: ssh ${var.ssh_user}@${aws_instance.redsmoke_server.public_ip} -i ${var.redsmoke_key_name}.pem"
}

output "vpn-create-client" {
  description = "The public IP for VPN access"
  value       = "Create a user and connect to the VPN: \nssh ${var.ssh_user}@${aws_instance.redsmoke_server.public_ip} -i ${var.redsmoke_key_name}.pem 'sudo docker exec -i vpn-unit addvpnuser ${var.vpn_user}' && ssh ${var.ssh_user}@${aws_instance.redsmoke_server.public_ip} -i ${var.redsmoke_key_name}.pem 'sudo cat /root/vpn-unit/openvpn/client/${var.vpn_user}.ovpn' > ${var.vpn_user}.ovpn && sudo openvpn --config ${var.vpn_user}.ovpn"
}
