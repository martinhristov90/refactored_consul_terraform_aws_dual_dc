module "vpc" {
  source = "git::https://github.com/martinhristov90/vpc_module.git"

  cidr_block = "192.168.0.0/24"
}

# Getting AMI with Consul installed as Systemd service.
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
  subnet_id = module.vpc.subnet_id
  # What SGs to apply to this instance
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  # ID of the key pair to be used to access this instance
  key_name = module.generate_keys_east.key_name
  #Public key to be used.
  public_key_ssh = module.generate_keys_east.public_key_ssh
  # Datacenter name
  datacenter = "dc-east"
  # Auto-join
  iam_instance_profile_name  = aws_iam_instance_profile.consul_instance_profile.name
  #auto_join_key_id     = aws_iam_access_key.auto_join_user_access_key.id
  #auto_join_secret_key = aws_iam_access_key.auto_join_user_access_key.secret
  # Number of consul servers in this DC
  instance_count = 1
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
  subnet_id = module.vpc.subnet_id
  # What SGs to apply to this instance
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  # ID of the key pair to be used to access this instance
  key_name = module.generate_keys_west.key_name
  #Public key to be used.
  public_key_ssh = module.generate_keys_west.public_key_ssh
  # Datacenter name
  datacenter = "dc-west"

  # Auto-join
  iam_instance_profile_name  = aws_iam_instance_profile.consul_instance_profile.name
  #auto_join_key_id     = aws_iam_access_key.auto_join_user_access_key.id
  #auto_join_secret_key = aws_iam_access_key.auto_join_user_access_key.secret
  # Number of consul servers in this DC
  instance_count = 1
}

# Getting auto-join working below 

# Creating policy, only DescribeInstances for auto-join user
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

#Giving permissions for the EC2s to assume that role
data "aws_iam_policy_document" "assume_role_consul_ec2" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]


    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# User to be used for Consul auto-join
resource "aws_iam_role" "auto_join_user" {
  name = "auto_join_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_consul_ec2.json
}

# Attaching the policy to the user
resource "aws_iam_role_policy_attachment" "auto_join_policy_attach" {
  role       = aws_iam_role.auto_join_user.name
  policy_arn = aws_iam_policy.auto_join_policy.arn
}

# Creating instance profile from a role
resource "aws_iam_instance_profile" "consul_instance_profile" {
  name = "consul-instance-profile"
  role = aws_iam_role.auto_join_user.name
}
