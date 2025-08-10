resource "aws_key_pair" "ssh" {
  key_name   = var.key_name
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-ssh-sg"
  description = "Allow SSH from anywhere"
  vpc_id      = aws_vpc.this.id
}

resource "aws_vpc_security_group_ingress_rule" "ssh_in" {
  security_group_id = aws_security_group.bastion_sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
  description       = "SSH from anywhere"
}

resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.bastion_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# EC2 in public subnet (eu-central-1a) using EXISTING key pair
resource "aws_instance" "bastion" {
  ami                         = "ami-04e601abe3e1a910f"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = { Name = "bastion-public" }
}

# EC2 in private subnet (eu-central-1a)
resource "aws_instance" "private" {
  ami                         = "ami-04e601abe3e1a910f"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = false

  tags = { Name = "private-ec2" }
}

# Security group for private EC2 to allow ICMP (ping) from bastion
resource "aws_security_group" "private_sg" {
  name        = "private-ec2-sg"
  description = "Allow ICMP from bastion host"
  vpc_id      = aws_vpc.this.id
}
resource "aws_security_group_rule" "private_icmp_in" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  security_group_id        = aws_security_group.private_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id
  description              = "Allow ICMP from bastion host"
}

resource "aws_vpc_security_group_egress_rule" "private_all_out" {
  security_group_id = aws_security_group.private_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
