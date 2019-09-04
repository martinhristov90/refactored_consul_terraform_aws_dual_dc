output "subnet_id" {
  value = aws_subnet.main.id
}

output "default_security_group_id" {
  value = aws_vpc.main.default_security_group_id
}
