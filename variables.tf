variable "vcd_api_url" {
  description = "vCD API URL"
  # This is the URL of the vCloud Director API.
  # For Swisscom DCS+ see this documentation:
  # https://dcsguide.scapp.swisscom.com/ug3/vcloud_director.html#cloud-director-api
  # Example: https://vcd-pod-charlie.swisscomcloud.com/api
}

variable "vcd_api_username" {
  description = "vCD API username"
  # The API username for vCloud Director access.
  # For Swisscom DCS+ see this documentation:
  # https://dcsguide.scapp.swisscom.com/ug3/dcs_portal.html#cloud-director-api-user
}

variable "vcd_api_password" {
  description = "vCD API password"
  # The API password for vCloud Director access.
  # For Swisscom DCS+ see this documentation:
  # https://dcsguide.scapp.swisscom.com/ug3/dcs_portal.html#cloud-director-api-user
}

variable "vcd_token" {
  default = ""
}
variable "vcd_auth_type" {
  default = "integrated"
}
variable "vcd_logging_enabled" {
  description = "Enable logging of vCD API interaction"
  default     = false
}

variable "vcd_org" {
  description = "vCD Organization"
  # The organization in vCloud Director.
  # For Swisscom DCS+ this is your Contract Id / PRO-Number (PRO-XXXXXXXXX)
}

variable "vcd_vdc" {
  description = "vCD Virtual Data Center"
  # The VDC in vCloud Director.
  # For Swisscom DCS+ this is your "Dynamic Data Center", see this documentation:
  # https://dcsguide.scapp.swisscom.com/ug3/dcs_portal.html#dynamic-data-center
}

variable "vcd_catalog" {
  description = "Catalog name"
  default     = "DCS Catalog"
  # The vCD catalog to use for your vApp templates.
  # For Swisscom DCS+ use "DCS Catalog", see this documentation:
  # https://dcsguide.scapp.swisscom.com/ug3/vcloud_director.html#catalogs
}

variable "vcd_template" {
  description = "vCD vApp template name"
  default     = "ubuntu1804-vmware-dcs-20220325"
  # The vApp template to use for your virtual machines.
  # For Swisscom DCS+ see this documentation:
  # https://dcsguide.scapp.swisscom.com/ug3/vcloud_director.html#vapp-templates
}

variable "vcd_edgegateway" {
  description = "vCD VDC Edge Gateway"
  # The edge gateway / virtual router of your VDC networks, necessary for internet access.
  # For Swisscom DCS+ see this documentation:
  # https://dcsguide.scapp.swisscom.com/ug3/vcloud_director.html#edges
}

variable "net_load_balancer_ip" {
  description = "Public IP Address of your load balancer"
  # The public IP of your load balancer
  # For Swisscom DCS+ see this documentation:
  # https://dcsguide.scapp.swisscom.com/ug3/vcloud_director.html#edge-load-balancing
}

variable "net_k8s_cidr" {
  description = "IP range for Kubernetes network in CIDR notation"
  default     = "10.0.80.0/24"
}

variable "k8s_cluster_name" {
  description = "K8s cluster name (vCD vApp)"
  default     = "kubernetes"
}

variable "k8s_bastion_root_password" {
  description = "root password of K8s bastion host"
}
variable "k8s_bastion_memory" {
  description = "Memory of K8s bastion host (in MB)"
  default     = 1024
}
variable "k8s_bastion_cpus" {
  description = "CPUs of K8s bastion host (in MB)"
  default     = 1
}

variable "k8s_control_plane_root_password" {
  description = "root password of K8s control plane nodes"
}
variable "k8s_control_plane_instances" {
  description = "Number of K8s control plane nodes (VMs)"
  default     = 3
}
variable "k8s_control_plane_memory" {
  description = "Memory of K8s control plane node (in MB)"
  default     = 2048
}
variable "k8s_control_plane_cpus" {
  description = "CPUs of K8s control plane node (in MB)"
  default     = 2
}

variable "k8s_worker_root_password" {
  description = "root password of K8s worker nodes"
}
variable "k8s_worker_instances" {
  description = "Number of K8s worker nodes (VMs)"
  default     = 3
}
variable "k8s_worker_memory" {
  description = "Memory of K8s worker node (in MB)"
  default     = 8192
}
variable "k8s_worker_cpus" {
  description = "CPUs of K8s worker node (in MB)"
  default     = 4
}

variable "k8s_k3s_version" {
  description = "Kubernetes version of K3s to use"
  default     = "v1.24.3+k3s1"
  # See https://github.com/k3s-io/k3s/releases
}