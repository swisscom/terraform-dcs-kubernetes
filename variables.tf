# ======================================================================================================================
# Module version
# ======================================================================================================================
variable "module_version" {
  description = "Version/Release of this module"
  default     = "v2.4.2"
  # See https://github.com/swisscom/terraform-dcs-kubernetes/releases
}

# ======================================================================================================================
# vCloud Director settings
# ======================================================================================================================
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
  # Login with a Bearer token instead of username/password if specified.
}
variable "vcd_auth_type" {
  default = "integrated"
  # Default login method is to use username/password.
}
variable "vcd_logging_enabled" {
  description = "Enable logging of vCD API interaction"
  default     = false
  # If enabled it will log API debug output into "go-vcloud-director.log"
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

variable "vcd_edgegateway" {
  description = "vCD VDC Edge Gateway"
  # The edge gateway / virtual router of your VDC networks, necessary for internet access.
  # For Swisscom DCS+ see this documentation:
  # https://dcsguide.scapp.swisscom.com/ug3/vcloud_director.html#edges
}

variable "vcd_catalog" {
  description = "Catalog name"
  default     = ""
  # The vCD catalog to use for your vApp templates. This is where the new Ubuntu OS image will be stored in.
  # If not specified or left empty it will use the K8s cluster name.
  # For Swisscom DCS+ see this documentation:
  # https://dcsguide.scapp.swisscom.com/ug3/vcloud_director.html#catalogs
}
variable "vcd_template" {
  description = "vCD vApp template name"
  default     = ""
  # The vApp template to use for your virtual machines. This is the name under which the new Ubuntu OS image will be stored.
  # If not specified or left empty it will use a generated name based on K8s cluster name.
  # For Swisscom DCS+ see this documentation:
  # https://dcsguide.scapp.swisscom.com/ug3/vcloud_director.html#vapp-templates
}
variable "vcd_ova_file" {
  description = "vCD vApp template OVA filename"
  default     = "ubuntu-22.04-server-cloudimg-amd64.ova"
  # The OVA filename/path to upload as a vApp template. Defaults to "ubuntu-22.04-server-cloudimg-amd64.ova", to be downloaded from https://cloud-images.ubuntu.com/jammy/current/ and placed into the current working directory:
  # wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.ova -O ubuntu-22.04-server-cloudimg-amd64.ova
}

# ======================================================================================================================
# Kubernetes settings
# ======================================================================================================================
variable "k8s_domain_name" {
  description = "DNS domain name of your Kubernetes cluster (Fallback to <edgegateway-IP>.nip.io if missing)"
  default     = ""
  # The DNS "A" entry of your Kubernetes cluster's external edgegateway/loadbalancer IP.
  # Please make sure to set an appropriate DNS entry after creating the edgegateway.
  # If you do not set a value here, the terraform module will fallback to using <edgegateway-IP>.nip.io.
}

variable "k8s_automatically_upgrade_os" {
  description = "Enables or disables automatic upgrades of OS packages (unattended-upgrades)"
  default     = true
  # Set this to 'false' if you do not want automatic apt package upgrades on your VMs.
}

variable "k8s_node_cidr" {
  description = "IP range for Kubernetes node network in CIDR notation"
  default     = "10.80.0.0/24"
}
variable "k8s_pod_cidr" {
  description = "IP range for Kubernetes pod network in CIDR notation"
  default     = "10.82.0.0/16"
}
variable "k8s_service_cidr" {
  description = "IP range for Kubernetes service network in CIDR notation"
  default     = "10.84.0.0/16"
}

variable "k8s_cluster_name" {
  description = "K8s cluster name (vCD vApp)"
  default     = "kubernetes"
}

variable "k8s_ssh_public_key" {
  description = "SSH public key of all K8s nodes"
}
variable "k8s_ssh_private_key" {
  description = "SSH private key of all K8s nodes"
}

# ======================================================================================================================
# Kubernetes resources
# ======================================================================================================================
variable "k8s_bastion_memory" {
  description = "Memory of K8s bastion host (in MB)"
  default     = 1024
}
variable "k8s_bastion_cpus" {
  description = "CPUs of K8s bastion host (in MB)"
  default     = 1
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
variable "k8s_worker_disk_size" {
  description = "Disk size of K8s worker node (in MB)"
  default     = 245760
}

# ======================================================================================================================
# Helm charts
# ======================================================================================================================
variable "k8s_enable_monitoring" {
  description = "Enable installation of Prometheus and Grafana on Kubernetes"
  default     = true
}
variable "k8s_enable_logging" {
  description = "Enable installation of Loki and Promtail on Kubernetes"
  default     = true
}
variable "k8s_enable_automatic_node_reboot" {
  description = "Enable automatic reboot of K8s nodes for OS upgrades"
  default     = true
  # Set this to 'false' if you don't want unattended, uncontrolled VM reboots (via kured) and/or your workload cannot handle pod rescheduling
}
variable "k8s_k3s_version" {
  description = "Kubernetes version of K3s to install"
  default     = "v1.24.7+k3s1"
  # See https://github.com/k3s-io/k3s/releases
}
variable "k8s_cilium_version" {
  description = "Cilium version to install"
  default     = "v1.12.3"
  # See https://github.com/cilium/cilium/releases
}
variable "k8s_cilium_cli_version" {
  description = "Cilium CLI version to use for Cilium installation"
  default     = "v0.12.6"
  # See https://github.com/cilium/cilium-cli/releases
}
variable "k8s_helm_longhorn_version" {
  description = "Helm chart version of Longhorn to install"
  default     = "1.3.2"
  # See https://artifacthub.io/packages/helm/longhorn/longhorn
}
variable "k8s_helm_kured_version" {
  description = "Helm chart version of Kured to install"
  default     = "4.1.0"
  # See https://artifacthub.io/packages/helm/kured/kured
}
variable "k8s_helm_ingress_nginx_version" {
  description = "Helm chart version of Ingress-NGINX to install"
  default     = "4.4.0"
  # See https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx
}
variable "k8s_helm_cert_manager_version" {
  description = "Helm chart version of Cert-Manager to install"
  default     = "1.10.0"
  # See https://artifacthub.io/packages/helm/cert-manager/cert-manager
}
variable "k8s_helm_kubernetes_dashboard_version" {
  description = "Helm chart version of Kubernetes-Dashboard to install"
  default     = "5.10.0"
  # See https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard
}
variable "k8s_helm_prometheus" {
  description = "Helm chart version of Prometheus to install"
  default     = "15.18.0"
  # See https://artifacthub.io/packages/helm/prometheus-community/prometheus
}
variable "k8s_helm_loki" {
  description = "Helm chart version of Loki to install"
  default     = "3.3.4"
  # See https://artifacthub.io/packages/helm/grafana/loki
}
variable "k8s_helm_promtail" {
  description = "Helm chart version of Promtail to install"
  default     = "6.6.1"
  # See https://artifacthub.io/packages/helm/grafana/promtail
}
variable "k8s_helm_grafana" {
  description = "Helm chart version of Grafana to install"
  default     = "6.43.5"
  # See https://artifacthub.io/packages/helm/grafana/grafana
}

# ======================================================================================================================
# Helm chart settings
# ======================================================================================================================
variable "k8s_cert_manager_lets_encrypt_server" {
  description = "ACME server for Let's Encrypt ClusterIssuer"
  default     = "https://acme-v02.api.letsencrypt.org/directory"
  # https://cert-manager.io/docs/concepts/issuer/
  # The default value is set to the production server.
  # Only set this to the staging environment if you want to do frequent development or testing.
  # See https://letsencrypt.org/docs/staging-environment/
}
