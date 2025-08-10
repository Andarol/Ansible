variable "aws_region" {
  default = "eu-central-1"
}

variable "ami_id" {
  default = "ami-04e601abe3e1a910f" # Ubuntu 22.04 LTS
}

variable "instance_type" {
  default = "t3.small"
}

variable "public_key_path" {
  default = "~/.ssh/id_ed25519.pub"
}

variable "security_group_name" {
  default = "wp-security-group"
}

variable "key_name" {
  default = "my_aws"
}
