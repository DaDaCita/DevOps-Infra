variable "name_prefix" {
  type = string
}

variable "cidr" {
  type = string
}

variable "azs" {
  type = list(any)
}

variable "private_subnets" {
  type = list(any)
}

variable "public_subnets" {
  type = list(any)
}

variable "cluster_name" {
  type = string
}

variable "autoscaling_average_cpu" {
  type = number
}