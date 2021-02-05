# Get default vCD org edge info
data "vcd_edgegateway" "edge" {
  filter {
    name_regex = "^.*$"
  }
}