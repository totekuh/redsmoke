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
  region  = "eu-central-1"
}

resource "aws_key_pair" "kraken-key" {
  key_name   = "kraken-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCi62yQq8uTmsgh5ga/+9Cc14V0I4YAFTsst0FN/f5UmwWmvAY9EGFXvGSrGGCY1iGFCSeI2fnsbrimj3nASDB6W4JrZ9ljlYDg+S3BiyL7eIq8WKAcSXkjbzWeYLhZ5GeNh13uR1N/AihWXxxRSEDpcvPyzmqcx2BJteSN+YWNYdlBHynBdpBnFDIRML7smBk4i+Qnxj7U8vSkjJ7D80ADaCEXUPsQC8ikYoFRh2BodRl/ypA3dmpTOqjjh00OzI1JeITaor1EszTNYtynJokgVikESo00tRLpq0b4unAHPqyAjlY66YvI/onsa+YUI/6lNqLhFbLYjU/URHQbZncIUf2KJejwl/A1h9/xV41d9r51/3KY+BNahCmUJT9Tr4UPIQGNxiSAAUH1qzwCe3lXHhPYn3PipYUzaaLEcBKaIDj5Yk4FswpuzjmIFtALtWWg3U3k0dz5vtaQjgZfYhZ9EFxOidTCu9BIwNPwKUsQb2JwMlm73U7HbNHgAMkURcE= totekuh@kraken"
}

resource "aws_security_group" "redform_security" {
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

resource "aws_instance" "redform_server" {
  ami           = "ami-0b1deee75235aa4bb"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.redform_security.id]
  key_name         = "kraken-key"

  tags = {
    Name = "RedFormInstance"
  }
}

output "instance_ip" {
  description = "The public ip for ssh access"
  value       = aws_instance.redform_server.public_ip
}