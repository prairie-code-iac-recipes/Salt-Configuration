variable "hosts" {
  type        = list
  description = "A list of DNS names and/or IP addresses for individual saltmaster instances."
}

variable "ssh_private_key" {
  type        = string
  description = "The contents of a base64-encoded SSH key to use for the connection."
}

variable "ssh_username" {
  type        = string
  description = "The user that we should use for the connection."
}
