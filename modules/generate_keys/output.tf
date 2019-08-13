output "public_key_ssh" {
  value = tls_private_key.keys.public_key_openssh
}

output "key_name" {
  value = var.key_name
}
