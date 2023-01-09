terraform {
  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = "~> 3.5.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.12.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 2.1.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "vcd" {
  url      = var.vcd_api_url
  user     = var.vcd_api_username
  password = var.vcd_api_password
  #token    = var.vcd_token
  org = var.vcd_org
  vdc = var.vcd_vdc

  auth_type            = var.vcd_auth_type
  max_retry_timeout    = 120
  allow_unverified_ssl = true

  logging = var.vcd_logging_enabled
}

module "infrastructure" {
  source = "./infrastructure"

  providers = {
    vcd = vcd
  }

  vcd_api_url         = var.vcd_api_url
  vcd_api_username    = var.vcd_api_username
  vcd_api_password    = var.vcd_api_password
  vcd_token           = var.vcd_token
  vcd_org             = var.vcd_org
  vcd_vdc             = var.vcd_vdc
  vcd_auth_type       = var.vcd_auth_type
  vcd_logging_enabled = var.vcd_logging_enabled
  vcd_catalog         = var.vcd_catalog
  vcd_template        = var.vcd_template
  vcd_ova_file        = var.vcd_ova_file
  vcd_edgegateway     = var.vcd_edgegateway

  k8s_node_cidr                = var.k8s_node_cidr
  k8s_cluster_name             = var.k8s_cluster_name
  k8s_ssh_public_key           = var.k8s_ssh_public_key
  k8s_ssh_private_key          = var.k8s_ssh_private_key
  k8s_automatically_upgrade_os = var.k8s_automatically_upgrade_os
  k8s_bastion_memory           = var.k8s_bastion_memory
  k8s_bastion_cpus             = var.k8s_bastion_cpus
  k8s_control_plane_instances  = var.k8s_control_plane_instances
  k8s_control_plane_memory     = var.k8s_control_plane_memory
  k8s_control_plane_cpus       = var.k8s_control_plane_cpus
  k8s_worker_instances         = var.k8s_worker_instances
  k8s_worker_memory            = var.k8s_worker_memory
  k8s_worker_cpus              = var.k8s_worker_cpus
  k8s_worker_disk_size         = var.k8s_worker_disk_size
}

resource "time_sleep" "wait_for_infrastructure" {
  create_duration = "30s"
  depends_on      = [module.infrastructure.k8s_nodes]
}

module "kubernetes" {
  source = "./kubernetes"

  providers = {
    tls  = tls
    http = http
  }

  k8s_node_cidr    = var.k8s_node_cidr
  k8s_pod_cidr     = var.k8s_pod_cidr
  k8s_service_cidr = var.k8s_service_cidr
  k8s_cluster_name = var.k8s_cluster_name

  k8s_ssh_private_key        = var.k8s_ssh_private_key
  k8s_bastion_username       = "kubernetes"
  k8s_control_plane_username = "kubernetes"
  k8s_worker_username        = "kubernetes"

  loadbalancer_ip = module.infrastructure.edge_gateway_external_ip
  domain_name     = var.k8s_domain_name

  k8s_bastion_ip              = module.infrastructure.edge_gateway_external_ip
  k8s_control_plane_instances = var.k8s_control_plane_instances
  k8s_worker_instances        = var.k8s_worker_instances

  module_version     = var.module_version
  k3s_version        = var.k8s_k3s_version
  cilium_version     = var.k8s_cilium_version
  cilium_cli_version = var.k8s_cilium_cli_version

  depends_on = [time_sleep.wait_for_infrastructure]
}

resource "time_sleep" "wait_for_kubernetes" {
  create_duration = "60s"
  depends_on = [
    module.kubernetes.kubernetes_ready,
    module.kubernetes.cilium_install_ready,
    module.kubernetes.cilium_status_ready
  ]
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.infrastructure.edge_gateway_external_ip}:6443"
    cluster_ca_certificate = module.kubernetes.cluster_ca_certificate
    client_certificate     = module.kubernetes.client_certificate
    client_key             = module.kubernetes.client_key
  }
}

provider "kubernetes" {
  host                   = "https://${module.infrastructure.edge_gateway_external_ip}:6443"
  cluster_ca_certificate = module.kubernetes.cluster_ca_certificate
  client_certificate     = module.kubernetes.client_certificate
  client_key             = module.kubernetes.client_key
}

provider "kubectl" {
  host                   = "https://${module.infrastructure.edge_gateway_external_ip}:6443"
  cluster_ca_certificate = module.kubernetes.cluster_ca_certificate
  client_certificate     = module.kubernetes.client_certificate
  client_key             = module.kubernetes.client_key
  load_config_file       = false
  apply_retry_count      = 5
}

module "deployments" {
  source = "./deployments"

  providers = {
    helm       = helm
    kubernetes = kubernetes
    kubectl    = kubectl
  }

  domain_name            = var.k8s_domain_name
  lets_encrypt_server    = var.k8s_cert_manager_lets_encrypt_server
  loadbalancer_ip        = module.infrastructure.edge_gateway_external_ip
  kubernetes_summary     = module.kubernetes.kubernetes_summary
  kubernetes_ready       = module.kubernetes.kubernetes_ready
  cilium_install_ready   = module.kubernetes.cilium_install_ready
  cilium_status_ready    = module.kubernetes.cilium_status_ready
  cluster_api_endpoint   = "https://${module.infrastructure.edge_gateway_external_ip}:6443"
  cluster_ca_certificate = module.kubernetes.cluster_ca_certificate
  client_certificate     = module.kubernetes.client_certificate
  client_key             = module.kubernetes.client_key

  enable_monitoring                 = var.k8s_enable_monitoring
  enable_logging                    = var.k8s_enable_logging
  enable_automatic_node_reboot      = var.k8s_enable_automatic_node_reboot
  cilium_version                    = var.k8s_cilium_version
  helm_longhorn_version             = var.k8s_helm_longhorn_version
  helm_kured_version                = var.k8s_helm_kured_version
  helm_ingress_nginx_version        = var.k8s_helm_ingress_nginx_version
  helm_cert_manager_version         = var.k8s_helm_cert_manager_version
  helm_kubernetes_dashboard_version = var.k8s_helm_kubernetes_dashboard_version
  helm_prometheus                   = var.k8s_helm_prometheus
  helm_loki                         = var.k8s_helm_loki
  helm_promtail                     = var.k8s_helm_promtail
  helm_grafana                      = var.k8s_helm_grafana

  depends_on = [time_sleep.wait_for_kubernetes]
}
