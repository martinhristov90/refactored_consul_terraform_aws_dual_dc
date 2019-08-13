output "public_ip_east" {
  value = module.consul_server_east.public_ip
}
output "public_ip_west" {
  value = module.consul_server_west.public_ip
}
