variable "network" {
  type = object({
    name = string
    cidr = string
    dns1 = string
    dns2 = string
  })
  
  description = "Network parameters"
}