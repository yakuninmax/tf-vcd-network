output "network" {
  value = length(var.networks) != 0 ? vcd_network_routed.network[*] : null
}

output "vapp" {
  value = var.vapp_name != "" ? vcd_vapp.vapp : null
}