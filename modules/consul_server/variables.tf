variable "public_key_ssh" {
  description = "public key to be used in creation of key-pair process"
}

variable "ami" {
  description = "AMI to create the instance from"
}

variable "subnet_id" {
  description = "ID of the subnet to created this instance in"
}

variable "vpc_security_group_ids" {
  type        = list
  description = "LIST of SGs"
}

variable "key_name" {
  description = "Name of an existing the key-pair "
}

variable "datacenter" {
  description = "Datacenter for the instance"
}

variable "instance_count" {
  description = "Sets a number of instances to be created"
}

variable "iam_instance_profile_name" {
  description = "provides the name of the instance profile used for cloud auto-join feature"
}



