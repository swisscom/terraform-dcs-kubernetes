# pre-provisioned vCD edge gateway
data "vcd_edgegateway" "k8s" {
  name = var.vcd_edgegateway
  org  = var.vcd_org
  vdc  = var.vcd_vdc
}

# vCD NSX-V network for Kubernetes nodes
resource "vcd_network_routed_v2" "k8s_nodes" {
  name = "k8s_nodes"

  interface_type  = "internal"
  edge_gateway_id = data.vcd_edgegateway.k8s.id
  gateway         = cidrhost(var.net_k8s_cidr, 1)
  prefix_length   = split("/", var.net_k8s_cidr)[1]
  dns1            = "1.1.1.1"
  dns2            = "8.8.8.8"

  static_ip_pool {
    start_address = cidrhost(var.net_k8s_cidr, 100)
    end_address   = cidrhost(var.net_k8s_cidr, 150)
  }
}

resource "vcd_nsxv_snat" "outbound" {
  edge_gateway = var.vcd_edgegateway

  network_type       = "org"
  network_name       = vcd_network_routed_v2.k8s_nodes.name
  original_address   = var.net_k8s_cidr
  translated_address = data.vcd_edgegateway.k8s.default_external_network_ip

  depends_on = ["vcd_network_routed_v2.k8s_nodes"]
}
