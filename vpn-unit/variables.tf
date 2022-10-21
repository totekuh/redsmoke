### if you change that don't forget to change the availability zone as well
variable "redform_region" {
  type        = string
  default     = "eu-central-1"
  description = "The AWS region to use"
}

### aws ec2 describe-availability-zones --region region-name
variable "redform_ebs_availability_zone" {
  type        = string
  default     = "eu-central-1a"
  description = "The availability zone to use while creating the EBS volume"
}

variable "redform_key_name" {
  type        = string
  default     = "redform-key-pair"
  description = "Key-pair generated by Redform"
}

variable "ami" {
  type        = string
  # Kali Linux image
  default     = "ami-0895913865fe4ae72"
  description = "The AMI of the server"
}

variable "redform_ebs_size" {
  type        = number
  default     = 10
  description = "The storage's size of the EBS volume in GB to be attached to the created EC2 instance"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
  description = "The type of the EC2 instance to create"
}

variable "instance_name" {
  type = string
  default = "redform-vpn-unit"
  description = "The EC2 instance name to set"
}

variable "ssh_user" {
  type        = string
  default     = "kali"
  description = "The username to use while connecting via SSH for provisioning"
}