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
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
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
    Name = "allow_ssh"
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
    timeout     = "1m"
  }

  provisioner "file" {
    source      = "scripts/install.sh"
    destination = "/tmp/install.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install.sh",
      "/tmp/install.sh"
    ]
  }
}

#########################################
### EBS VOLUMES/ATTACHMENTS CONFIGURATION
#########################################

resource "aws_ebs_volume" "redform_ebs" {
  availability_zone = var.redform_ebs_availability_zone
  size              = var.redform_ebs_size

  tags = {
    Name = "Redform Storage"
  }
}

resource "aws_volume_attachment" "redform_ebs_attachment" {
  # attach as the root volume
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.redform_ebs.id
  instance_id = aws_instance.redform_server.id
}

output "connect_cmd" {
  description = "The public ip for SSH access"
  value       = "ssh ${var.ssh_user}@${aws_instance.redform_server.public_ip} -i ${var.redform_key_name}.pem"
}

