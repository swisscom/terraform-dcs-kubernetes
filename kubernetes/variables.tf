variable "module_version" {}

variable "k8s_node_cidr" {
  default = "10.80.0.0/24"
}
variable "k8s_pod_cidr" {
  default = "10.82.0.0/16"
}
variable "k8s_service_cidr" {
  default = "10.84.0.0/16"
}

variable "k8s_cluster_name" {
  default = "kubernetes"
}

variable "loadbalancer_ip" {}
variable "domain_name" {}

variable "k8s_bastion_ip" {}
variable "k8s_bastion_port" {
  default = 2222
}
variable "k8s_bastion_username" {}

variable "k8s_control_plane_instances" {}
variable "k8s_control_plane_username" {}

variable "k8s_worker_instances" {}
variable "k8s_worker_username" {}

variable "k8s_ssh_private_key" {}

variable "k3s_version" {}
variable "cilium_version" {}
variable "cilium_cli_version" {}
