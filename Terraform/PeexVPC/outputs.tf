output "vpc_id"            { value = aws_vpc.this.id }
output "public_subnet_id"  { value = aws_subnet.public.id }
output "private_subnet_id" { value = aws_subnet.private.id }
output "bastion_public_ip" { value = aws_instance.bastion.public_ip }
output "private_ec2_private_ip" { value = aws_instance.private.private_ip }
output "ssh_example" {
  value = "ssh -i ~/.ssh/id_ed25519 ubuntu@${aws_instance.bastion.public_ip}"
}