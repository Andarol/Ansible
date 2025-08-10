provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "wp_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "wp_sg" {
  name        = var.security_group_name
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "wordpress" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.wp_key.key_name
  vpc_security_group_ids      = [aws_security_group.wp_sg.id]
  associate_public_ip_address = true

  provisioner "file" {
    source      = "${path.module}/wordpress.pp"
    destination = "/tmp/wordpress.pp"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_ed25519")
      host        = self.public_ip
    }
  }

 provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y software-properties-common",
      "sudo add-apt-repository -y universe",
      "sudo apt update",
      "wget https://apt.puppet.com/puppet7-release-jammy.deb -O /tmp/puppet7.deb",
      "sudo dpkg -i /tmp/puppet7.deb",
      "sudo apt update",
      "sudo apt install -y puppet-agent",
      "sudo ln -s /opt/puppetlabs/bin/puppet /usr/bin/puppet",
      "sudo mkdir -p /var/www/html",
      "sudo puppet apply /tmp/wordpress.pp"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_ed25519")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "wordpress-instance"
  }
}
