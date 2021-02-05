variable "dnat_rules" {
  type = list(object({
    original_address   = string
    original_port      = number
    translated_address = string
    translated_port    = number
    protocol           = string
    description        = string
  }))
  
  description = "List of DNAT rules"
  default     = []
}

variable "firewall_rules" {
  type = list(object({
    name        = string
    source      = string
    destination = string
    protocol    = string
    port        = string
  }))
  
  description = "List of firewall rules"
  default     = []
}

variable "networks" {
  type = list(object({
    name = string
    cidr = string
    dns1 = string
    dns2 = string
  }))
  
  description = "List of networks"
  default     = []
}

variable "snat_rules" {
  type        = list(object({
    original_address   = string
    translated_address = string
    description        = string
  }))

  description = "List of SNAT rules"
  default     = []
}

variable "vapp_name" {
  type = string
  description = "New vApp name"
  default = ""
}