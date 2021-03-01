# Create new org network
resource "vcd_network_routed" "network" {
  name         = var.name
  edge_gateway = data.vcd_edgegateway.edge.name
  gateway      = cidrhost(var.cidr, 1)
  netmask      = cidrnetmask(var.cidr)
  dns1         = var.dns1 != "" ? var.dns1 : null
  dns2         = var.dns2 != "" ? var.dns2 : null
        
  static_ip_pool {
    start_address = cidrhost(var.cidr, 10)
    end_address   = cidrhost(var.cidr, 99)
  }
}

# Create default SNAT and DNAT rules
resource "vcd_nsxv_snat" "default-snat-rule" {  
  depends_on = [vcd_network_routed.network]
  
  edge_gateway       = data.vcd_edgegateway.edge.name
  network_type       = "ext"
  network_name       = tolist(data.vcd_edgegateway.edge.external_network)[0].name
  original_address   = var.cidr
  translated_address = data.vcd_edgegateway.edge.external_network_ips[0]
  description        = "From ${var.name} to Internet"
}

# Create default firewall rules
resource "vcd_nsxv_firewall_rule" "default-firewall-rule" {  
  edge_gateway = data.vcd_edgegateway.edge.name
  name         = "From ${var.name} to Internet"

  source {
    ip_addresses = [var.cidr]
  }

  destination {
    gateway_interfaces = ["external"]
  }

  service {
    protocol = "any"
    port     = "any"
  }
}