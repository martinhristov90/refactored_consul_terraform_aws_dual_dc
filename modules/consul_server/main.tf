# Key pair to be used for the EC2
resource "aws_key_pair" "consul_server_keypair" {
  key_name   = var.key_name
  public_key = var.public_key_ssh
}

resource "aws_instance" "consul_server" {
  # Run this particular Ubuntu Consul AMI
  ami = var.ami
  # How many servers to be created 
  count = var.instance_count
  # Subnet ID this instance to be associated with.
  subnet_id = var.subnet_id
  # What SGs to apply to this instance
  vpc_security_group_ids = var.vpc_security_group_ids
  # ID of the key pair to be used to access this instance
  key_name = aws_key_pair.consul_server_keypair.key_name
  # Size of the instance
  instance_type = "t2.micro"
  # Providing instance profile for auto join feature
  iam_instance_profile = var.iam_instance_profile_name

  # Setting up consul server with template file
  user_data = templatefile("${path.module}/../../configs/consul_server/provision.tmpl", {
    datacenter           = var.datacenter
    instance_number      = count.index
  })

  tags = {
    # This tag is used for WAN join
    Name = "consul-server"
    # This tag is used for LAN join
    lan_name = "consul-server-${var.datacenter}"
  }
}