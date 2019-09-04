# This is the VPC in which all resources are going to be crated.
resource "aws_vpc" "main" {
  # cidr_block for whole VPC, all subnets inside the VPC should be in this address space.
  cidr_block = var.cidr_block
  # Those two lines enable DNS support, every instance lunched in this VPC is going to get DNS record to its public IP.
  enable_dns_support   = true
  enable_dns_hostnames = true
  # Classic link improves isolation of the VPC.
  enable_classiclink = false
  # The VPC can run on shared hardware.
  instance_tenancy = "default"

  tags = {
    Name = "testing-vpc"
  }
}

# Main subnet to be used in the main VPC.
resource "aws_subnet" "main" {
  # ID of the VPC to associate the subnet with.
  vpc_id = aws_vpc.main.id
  # This cidr should be part of the network space of the VPC defined above.
  cidr_block = cidrsubnet(var.cidr_block, 1, 0)
  # Give public addresses to all instances lunched in this subnet
  map_public_ip_on_launch = "true"
  # Self-explanatory
  availability_zone = "us-east-1a"

  tags = {
    Name = "testing-vpc-subnet-1"
  }
}

# SG 
# Open port 22 to outside world
resource "aws_security_group_rule" "ssh_allow" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_vpc.main.default_security_group_id
  description       = "allowing inbound ssh connectivity"
}

# Internet GW
resource "aws_internet_gateway" "testing-vpc-gw" {
  # ID of the VPC to be created in, later it is going to be associated with routing table.
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "testing-igw"
  }
}
# New route table entry for default GW
resource "aws_route" "default_gw_entry" {
  route_table_id         = aws_vpc.main.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.testing-vpc-gw.id

}