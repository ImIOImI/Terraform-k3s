variable "environment" {
  type = string
}

variable "ami" {
  type = string
}

variable "domain" {
  type = string
}

variable "name" {
  type = string
}

variable "ssh_key_name" {
  type = string
}


variable "ssl_cert" {
  type = string
}

variable "server_security_groups" {
  type = list(string)
}

variable "elb_security_groups" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "instance_size" {
  type = string
}

variable "cloud-init" {
  type = string
}

variable "max" {
  type = number
  default = 3
}

variable "min" {
  type = number
  default = 3
}

variable "desired" {
  type = number
  default = 3
}

variable "iam_role" {
  type = string
}

variable "tags" {
  
}

