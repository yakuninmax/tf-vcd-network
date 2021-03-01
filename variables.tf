variable "name" {
  type        = string
  description = "Network name"
}

variable "cidr" {
  type        = string
  description = "Network CIDR"
}

variable "dns1" {
  type        = string
  description = "Network first DNS server address"
}

variable "dns2" {
  type        = string
  description = "Network second DNS server address"
}