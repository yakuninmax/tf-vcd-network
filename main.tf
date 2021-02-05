# Create new org network
resource "vcd_network_routed" "network" {
  count = length(var.networks)
   
  name         = var.networks[count.index].name
  edge_gateway = data.vcd_edgegateway.edge.name
  gateway      = cidrhost(var.networks[count.index].cidr, 1)
  netmask      = cidrnetmask(var.networks[count.index].cidr)
  dns1         = var.networks[count.index].dns1 != "" ? var.networks[count.index].dns1 : null
  dns2         = var.networks[count.index].dns2 != "" ? var.networks[count.index].dns2 : null
        
  static_ip_pool {
    start_address = cidrhost(var.networks[count.index].cidr, 10)
    end_address   = cidrhost(var.networks[count.index].cidr, 99)
  }
}

# Create default SNAT and DNAT rules
resource "vcd_nsxv_snat" "default-snat-rule" {  
  depends_on = [vcd_network_routed.network]
  count      = length(var.networks)
  
  edge_gateway       = data.vcd_edgegateway.edge.name
  network_type       = "ext"
  network_name       = tolist(data.vcd_edgegateway.edge.external_network)[0].name
  original_address   = var.networks[count.index].cidr
  translated_address = data.vcd_edgegateway.edge.external_network_ips[0]
  description        = "From ${var.networks[count.index].name} to Internet"
}

# Create default firewall rules
resource "vcd_nsxv_firewall_rule" "default-firewall-rule" {  
  count = length(var.networks)

  edge_gateway = data.vcd_edgegateway.edge.name
  name         = "From ${var.networks[count.index].name} to Internet"

  source {
    ip_addresses = [var.networks[count.index].cidr]
  }

  destination {
    gateway_interfaces = ["external"]
  }

  service {
    protocol = "any"
    port     = "any"
  }
}

# Create SNAT rules
resource "vcd_nsxv_snat" "snat-rule" {   
  count = length(var.snat_rules)
  
  edge_gateway       = data.vcd_edgegateway.edge.name
  network_type       = "ext"
  network_name       = tolist(data.vcd_edgegateway.edge.external_network)[0].name
  original_address   = var.snat_rules[count.index].original_address
  translated_address = var.snat_rules[count.index].translated_address !="" ? var.snat_rules[count.index].translated_address : data.vcd_edgegateway.edge.external_network_ips[0]
  description        = var.snat_rules[count.index].description !="" ? var.snat_rules[count.index].description : "From ${var.snat_rules[count.index].original_address} to ${var.snat_rules[count.index].translated_address !="" ? var.snat_rules[count.index].translated_address : data.vcd_edgegateway.edge.external_network_ips[0]}"
}

# Create DNAT rules
resource "vcd_nsxv_dnat" "dnat-rule" {   
  count = length(var.dnat_rules)
  
  edge_gateway       = data.vcd_edgegateway.edge.name
  network_type       = "ext"
  network_name       = tolist(data.vcd_edgegateway.edge.external_network)[0].name  
  original_address   = var.dnat_rules[count.index].original_address != "" ? var.dnat_rules[count.index].original_address : data.vcd_edgegateway.edge.external_network_ips[0]
  original_port      = var.dnat_rules[count.index].original_port
  translated_address = var.dnat_rules[count.index].translated_address
  translated_port    = var.dnat_rules[count.index].translated_port
  protocol           = var.dnat_rules[count.index].protocol
  description        = var.dnat_rules[count.index].description !="" ? var.dnat_rules[count.index].description : "From ${var.dnat_rules[count.index].original_address !="" ? var.dnat_rules[count.index].original_address : data.vcd_edgegateway.edge.external_network_ips[0]}:${var.dnat_rules[count.index].original_port} to ${var.dnat_rules[count.index].translated_address}:${var.dnat_rules[count.index].translated_port}"
}

# Create firewall rules
resource "vcd_nsxv_firewall_rule" "firewall-rule" {   
  count = length(var.firewall_rules)

  edge_gateway = data.vcd_edgegateway.edge.name
  name         = var.firewall_rules[count.index].name !="" ? var.firewall_rules[count.index].name : "From ${var.firewall_rules[count.index].source} to ${var.firewall_rules[count.index].destination}"

  source {
    ip_addresses = [var.firewall_rules[count.index].source]
  }

  destination {
    ip_addresses = [var.firewall_rules[count.index].destination]
  }

  service {
    protocol = var.firewall_rules[count.index].protocol
    port     = var.firewall_rules[count.index].port
  }
}

# Create new vApp
resource "vcd_vapp" "vapp" {
  count = var.vapp_name != "" ? 1 : 0

  name = var.vapp_name
}

# Add new networks to new vApp
resource "vcd_vapp_org_network" "vapp-network" {
  count = var.vapp_name != "" ? length(var.networks) : 0
  depends_on = [vcd_vapp.vapp]

  vapp_name        = var.vapp_name
  org_network_name = vcd_network_routed.network[count.index].name
}