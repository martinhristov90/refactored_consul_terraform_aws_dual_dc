module "vpc" {
  # This module creates VPC, subnets private and public inside it, NAT gataways and route tables.
  source = "terraform-aws-modules/vpc/aws"

  name = "consul-vpc"
  cidr = "192.168.0.0/24"
  # Private subnets
  azs                   = ["us-east-1a"]
  private_subnets       = ["192.168.0.0/26"]
  private_subnet_suffix = "private_"
  # Public subnets
  public_subnets       = ["192.168.0.64/26"]
  public_subnet_suffix = "public_"

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "consul-VPC"
  }
}


resource "aws_security_group_rule" "ssh_allow" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpc.default_security_group_id
  description       = "allowing inbound ssh connectivity"
}

data "aws_ami" "ami_details" {
  #executable_users = ["self"]
  most_recent = true
  name_regex  = "^packer-consul-\\d{10}"
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-consul-*"]
  }
}

# Generates public and private key to be used for the keypair
# The private key to connect to the EC2 is saved in PROJECT_ROOT/private_keys
module "generate_keys_east" {
  source   = "./modules/generate_keys"
  key_name = "consul_server_key_east"
}

# Creates Consul server
module "consul_server_east" {
  source = "./modules/consul_server"

  # Run this particular Ubuntu AMI
  ami = data.aws_ami.ami_details.image_id
  # Subnet ID this instance to be associated with.
  subnet_id = module.vpc.public_subnets[0]
  # What SGs to apply to this instance
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  # ID of the key pair to be used to access this instance
  key_name = module.generate_keys_east.key_name
  #Public key to be used.
  public_key_ssh = module.generate_keys_east.public_key_ssh
  # Datacenter name
  datacenter = "dc-east"
  # Auto-join
  auto_join_key_id     = aws_iam_access_key.auto_join_user_access_key.id
  auto_join_secret_key = aws_iam_access_key.auto_join_user_access_key.secret
  # Number of consul servers in this DC
  instance_count = 3
}

# Generates public and private key to be used for the keypair
# The private key to connect to the EC2 is saved in PROJECT_ROOT/private_keys
module "generate_keys_west" {
  source   = "./modules/generate_keys"
  key_name = "consul_server_key_west"
}

# Creates Consul server
module "consul_server_west" {
  source = "./modules/consul_server"

  # Run this particular Ubuntu AMI
  ami = data.aws_ami.ami_details.image_id
  # Subnet ID this instance to be associated with.
  subnet_id = module.vpc.public_subnets[0]
  # What SGs to apply to this instance
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  # ID of the key pair to be used to access this instance
  key_name = module.generate_keys_west.key_name
  #Public key to be used.
  public_key_ssh = module.generate_keys_west.public_key_ssh
  # Datacenter name
  datacenter = "dc-west"
  # Auto-join
  auto_join_key_id     = aws_iam_access_key.auto_join_user_access_key.id
  auto_join_secret_key = aws_iam_access_key.auto_join_user_access_key.secret
  # Number of consul servers in this DC
  instance_count = 3
}

# Getting auto-join working below 

# Creating policy, only DescribeInstances
resource "aws_iam_policy" "auto_join_policy" {
  name        = "auto_join_policy"
  path        = "/"
  description = "Policy for auto-joining"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "ec2:DescribeInstances"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
}
EOF
}

# User to be used for Consul auto-join
resource "aws_iam_user" "auto_join_user" {
  name = "auto_join_user"
}

# Attaching the policy to the user
resource "aws_iam_user_policy_attachment" "auto_join_policy_attach" {
  user       = aws_iam_user.auto_join_user.name
  policy_arn = aws_iam_policy.auto_join_policy.arn
}
# Getting programatic access
resource "aws_iam_access_key" "auto_join_user_access_key" {
  user = aws_iam_user.auto_join_user.name
}