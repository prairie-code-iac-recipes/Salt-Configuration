variable "hosts" {
  type        = list
  description = "A list of DNS names and/or IP addresses for individual saltmaster instances."
}

variable "role" {
  type        = string
  description = "Identifies the server role the the specified hosts should be assigned to."
}

variable "ssh_username" {
  type        = string
  description = "The user that we should use for the connection."
}

variable "ssh_private_key" {
  type        = string
  description = "The contents of an SSH key to use for the connection."
}

variable "wait_on" {
  type = list
  default = []
  description = "This module will wait for any resources listed to complete before it starts executing."
}
