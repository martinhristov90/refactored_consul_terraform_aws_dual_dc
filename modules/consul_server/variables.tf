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

variable "auto_join_key_id" {
  description = "The id of the key used to perform auto-join in Consul"
}

variable "auto_join_secret_key" {
  description = "The secret key used to auto-join in Consul"
}



