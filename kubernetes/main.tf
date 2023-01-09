terraform {
  required_providers {
    tls = {
      source = "hashicorp/tls"
    }
    http = {
      source = "hashicorp/http"
    }
  }
}

module "k3s" {
  source  = "xunleii/k3s/module"
  version = "v3.1.0"

  use_sudo       = true
  k3s_version    = var.k3s_version
  drain_timeout  = "600s"
  managed_fields = ["label", "taint", "annotation"]

  cidr = {
    pods     = var.k8s_pod_cidr
    services = var.k8s_service_cidr
  }

  servers = {
    for i in range(var.k8s_control_plane_instances) :
    "k8s-server-${i}" => {
      ip = cidrhost(var.k8s_node_cidr, 50 + i)
      connection = {
        user                = var.k8s_control_plane_username
        private_key         = var.k8s_ssh_private_key
        bastion_host        = var.k8s_bastion_ip
        bastion_port        = var.k8s_bastion_port
        bastion_user        = var.k8s_bastion_username
        bastion_private_key = var.k8s_ssh_private_key
        timeout             = "15m"
      }
      flags = [
        "--write-kubeconfig-mode '0644'",
        "--node-taint CriticalAddonsOnly=true:NoExecute",
        "--kube-controller-manager-arg allocate-node-cidrs",
        "--flannel-backend none",
        "--disable-kube-proxy",
        "--disable-network-policy",
        "--disable traefik",
        "--disable local-storage",
        "--tls-san ${var.loadbalancer_ip}",
        "--tls-san ${var.domain_name != "" ? var.domain_name : "${var.loadbalancer_ip}.nip.io"}"
      ]
      labels = { "node.kubernetes.io/type" = "master" }
      annotations = {
        "server.index" : i,
        "dcs.kubernetes.io/release" : "'${var.module_version}'"
      }
    }
  }

  agents = {
    for i in range(var.k8s_worker_instances) :
    "k8s-worker-${i}" => {
      ip = cidrhost(var.k8s_node_cidr, 100 + i)
      connection = {
        user                = var.k8s_worker_username
        private_key         = var.k8s_ssh_private_key
        bastion_host        = var.k8s_bastion_ip
        bastion_port        = var.k8s_bastion_port
        bastion_user        = var.k8s_bastion_username
        bastion_private_key = var.k8s_ssh_private_key
        timeout             = "15m"
      }
      labels = { "node.kubernetes.io/pool" = "worker" }
      annotations = {
        "worker.index" : i,
        "dcs.kubernetes.io/release" : "'${var.module_version}'"
      }
    }
  }
}
