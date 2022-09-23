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
  region  = var.redform_region
}

#########################################
### SSH KEYS
#########################################



resource "tls_private_key" "redform_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "redform_key_pair" {
  key_name   = var.redform_key_name
  public_key = tls_private_key.redform_ssh_key.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      echo "${tls_private_key.redform_ssh_key.private_key_pem}" > ./"${var.redform_key_name}".pem
      chmod 400 ./'${var.redform_key_name}'.pem
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

resource "aws_security_group" "redform_security" {
  ### the ssh service exposed to the Internet
  ingress {
    description      = "SSH From Everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "HTTP From Everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "HTTPS From Everywhere"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
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
    Name = "redform_sg"
  }
}

#########################################
### EC2 CONFIGURATION
#########################################

resource "aws_instance" "redform_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.redform_security.id]
  key_name               = aws_key_pair.redform_key_pair.key_name

  tags = {
    Name = var.instance_name
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file("${var.redform_key_name}.pem")
    host        = aws_instance.redform_server.public_ip
    timeout     = "2m"
  }
  provisioner "file" {
    source      = "scripts/1-initial-setup.sh"
    destination = "/tmp/1-initial-setup.sh"
  }
  provisioner "file" {
    source      = "scripts/2-prepare-metasploit-daemon.sh"
    destination = "/tmp/2-prepare-metasploit-daemon.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "/bin/bash /tmp/1-initial-setup.sh",
      "/bin/bash /tmp/2-prepare-metasploit-daemon.sh ${var.msfd_ip} ${var.msfd_port}"
    ]
  }
}

output "connect_cmd" {
  description = "The public ip for SSH access"
  value       = "SSH service available: ssh ${var.ssh_user}@${aws_instance.redform_server.public_ip} -i ${var.redform_key_name}.pem"
}
output "connect_msfd" {
  description = "The address of the Metasploit daemon"
  value       = "Metasploit daemon deployed on remote at tcp://${var.msfd_ip}:${var.msfd_port}"
}
