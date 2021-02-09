output "networks" {
  value = length(var.networks) != 0 ? vcd_network_routed.network[*].name : null
}

output "subnets" {
  value = length(var.networks) != 0 ? var.networks[*].cidr : null
}

output "vapp" {
  value = var.vapp_name != "" ? vcd_vapp.vapp[0].vapp_name : null
}
