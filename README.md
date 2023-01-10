# terraform-dcs-kubernetes

[![Build](https://img.shields.io/github/actions/workflow/status/swisscom/terraform-dcs-kubernetes/test.yml?branch=master&label=Build)](https://github.com/swisscom/terraform-dcs-kubernetes/actions/workflows/master.yml)
[![License](https://img.shields.io/badge/License-Apache--2.0-lightgrey)](https://github.com/swisscom/terraform-dcs-kubernetes/blob/master/LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Kubernetes-blue)](https://kubernetes.io/)
[![IaC](https://img.shields.io/badge/IaC-Terraform-purple)](https://www.terraform.io/)

Deploy a Kubernetes cluster on [Swisscom DCS+](https://dcsguide.scapp.swisscom.com/)

### Quick start

Check out the [installation guide](docs/installation.md) for requirements, configuration and how to deploy a cluster. 

-----

Table of Contents
=================
* [Kubernetes cluster with k3s](#kubernetes-cluster-with-k3s)
  + [Architecture](#architecture)
  + [Components on cluster](#components-on-cluster)
* [Installation](#installation)
* [Up and running](#up-and-running)
  + [kubectl](#kubectl)
  + [DCS+](#dcs)
  + [Kubernetes-Dashboard](#kubernetes-dashboard)
  + [Grafana](#grafana)
  + [Longhorn](#longhorn)
  + [Cilium Hubble UI](#cilium-hubble-ui)
* [Troubleshooting](docs/troubleshooting.md)

## Kubernetes cluster with k3s

This Terraform module supports you in creating a Kubernetes cluster with [K3s](https://k3s.io/) on [Swisscom DCS+](https://www.swisscom.ch/en/business/enterprise/offer/cloud/cloudservices/dynamic-computing-services.html) infrastructure. It also installs and manages additional deployments on the cluster, such as cilium, ingress-nginx, cert-manager, longhorn, and a whole set of logging/metrics/monitoring related components.
It consists of three different submodules, [infrastructure](/infrastructure/), [kubernetes](/kubernetes/) and [deployments](/deployments/). Each of these is responsible for a specific subset of features provided by the overall Terraform module.

The **infrastructure** module will provision resources on DCS+ and setup a private internal network (10.80.0.0/24 CIDR by default), attach an Edge Gateway with an external public IP and configure loadbalancing services, deploy a bastion host (jumphost) for external SSH access into the private network, and finally a set of Kubernetes control plane and worker nodes for hosting your workload.

The **kubernetes** module will then connect via SSH over the bastion host to all those control plane and worker nodes and install a K3s Kubernetes cluster on them.

Finally the **deployments** module is responsible for installing system components and software on to the Kubernetes cluster. It does most of its work through the official Helm charts of each component, plus some additional customization directly via kubectl / manifests.

The final result is a fully functioning, highly available Kubernetes cluster, complete with all the batteries included you need to get you started. *Ingress* Controller for HTTP virtual hosting / routing, TLS certificate management with automatic Let's Encrypt certificates for all your HTTPS traffic, *PersistentVolume* and storage management with optional backups, and an entire monitoring stack for metrics and logs.

### Architecture
![DCS+ Kubernetes Architecture](https://raw.githubusercontent.com/JamesClonk/terraform-vcloud-kubernetes/data/dcs_k8s.png)

### Components on cluster

| Component | Type | Description |
| --- | --- | --- |
| [Cilium](https://cilium.io/) | Networking | An open-source, cloud native and eBPF-based Kubernetes CNI that is providing, securing and observing network connectivity between container workloads |
| [Longhorn](https://longhorn.io/) | Storage | Highly available persistent storage for Kubernetes, provides cloud-native block storage with backup functionality |
| [Ingress NGINX](https://kubernetes.github.io/ingress-nginx/) | Routing | Provides HTTP traffic routing, load balancing, SSL termination and name-based virtual hosting |
| [Cert Manager](https://cert-manager.io/) | Certificates | Cloud-native, automated TLS certificate management and [Let's Encrypt](https://letsencrypt.org/) integration for Kubernetes |
| [Kubernetes Dashboard](https://github.com/kubernetes/dashboard) | Dashboard | A general purpose, web-based UI for Kubernetes clusters that allows users to manage and troubleshoot applications on the cluster, as well as manage the cluster itself |
| [Prometheus](https://prometheus.io/) | Metrics | An open-source systems monitoring and alerting platform, collects and stores metrics in a time series database |
| [Loki](https://grafana.com/oss/loki/) | Logs | A horizontally scalable, highly available log aggregation and storage system |
| [Promtail](https://grafana.com/docs/loki/latest/clients/promtail/) | Logs | An agent which collects and ships the contents of logs on Kubernetes into the Loki log storage |
| [Grafana](https://grafana.com/oss/grafana/) | Dashboard | Allows you to query, visualize, alert on and understand all of your Kubernetes metrics and logs |
| [Kured](https://kured.dev/) | System | A daemonset that performs safe automatic node reboots when needed by the package management system of the underlying OS |

---

# Installation

Please refer to our [installation documentation](docs/installation.md) for detailed information about:
- System [requirements](docs/installation.md#requirements)
- Terraform [configuration](docs/installation.md#configuration)
- Cluster [provisioning](docs/installation.md#provisioning)

---

## Up and running

After the initial installation or upgrade with `terraform apply` has finished, you should see a couple of output parameters in your terminal:
```bash
Outputs:

cluster_info = "export KUBECONFIG=kubeconfig; kubectl cluster-info; kubectl get pods -A"
grafana_admin_password = "export KUBECONFIG=kubeconfig; kubectl -n grafana get secret grafana -o jsonpath='{.data.admin-password}' | base64 -d; echo"
grafana_url = "https://grafana.my-kubernetes.my-domain.com"
kubernetes_dashboard_token = "export KUBECONFIG=kubeconfig; kubectl -n kubernetes-dashboard create token kubernetes-dashboard"
kubernetes_dashboard_url = "https://dashboard.my-kubernetes.my-domain.com"
loadbalancer_ip = "147.5.206.133"
longhorn_dashboard = "export KUBECONFIG=kubeconfig; kubectl -n longhorn-system port-forward service/longhorn-frontend 9999:80"
```
These give you a starting point and some example commands you can run to access and use your newly provisioned Kubernetes cluster.

### kubectl

There should be a `kubeconfig` file written to the Terraform module working directory. This file contains the configuration and credentials to access and manage your Kubernetes cluster. You can set the environment variable `KUBECONFIG` to this file to have your `kubectl` CLI use it for the remainder of your terminal session.
```bash
$ export KUBECONFIG=$(pwd)/kubeconfig
```
Now you can run any `kubectl` commands you want to manage your cluster, for example:
```bash
$ kubectl cluster-info
Kubernetes control plane is running at https://147.5.206.133:6443
CoreDNS is running at https://147.5.206.133:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://147.5.206.133:6443/api/v1/namespaces/kube-system/services/https:metrics-server:https/proxy

$ kubectl get nodes -o wide
NAME           STATUS   ROLES                       AGE   VERSION        INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
k8s-server-0   Ready    control-plane,etcd,master   40h   v1.24.3+k3s1   10.80.0.50    <none>        Ubuntu 22.04.1 LTS   5.15.0-46-generic   containerd://1.6.6-k3s1
k8s-server-1   Ready    control-plane,etcd,master   40h   v1.24.3+k3s1   10.80.0.51    <none>        Ubuntu 22.04.1 LTS   5.15.0-46-generic   containerd://1.6.6-k3s1
k8s-server-2   Ready    control-plane,etcd,master   40h   v1.24.3+k3s1   10.80.0.52    <none>        Ubuntu 22.04.1 LTS   5.15.0-46-generic   containerd://1.6.6-k3s1
k8s-worker-0   Ready    <none>                      39h   v1.24.3+k3s1   10.80.0.100   <none>        Ubuntu 22.04.1 LTS   5.15.0-46-generic   containerd://1.6.6-k3s1
k8s-worker-1   Ready    <none>                      39h   v1.24.3+k3s1   10.80.0.101   <none>        Ubuntu 22.04.1 LTS   5.15.0-46-generic   containerd://1.6.6-k3s1
k8s-worker-2   Ready    <none>                      39h   v1.24.3+k3s1   10.80.0.102   <none>        Ubuntu 22.04.1 LTS   5.15.0-46-generic   containerd://1.6.6-k3s1

$ kubectl get namespaces
NAME                   STATUS   AGE
cert-manager           Active   39h
default                Active   40h
grafana                Active   37h
ingress-nginx          Active   39h
kube-node-lease        Active   40h
kube-public            Active   40h
kube-system            Active   40h
kubernetes-dashboard   Active   39h
loki                   Active   36h
longhorn-system        Active   39h
prometheus             Active   37h
promtail               Active   36h
```

### DCS+
![DCS+ Dashboard](https://raw.githubusercontent.com/JamesClonk/terraform-vcloud-kubernetes/data/dcs_dashboard.png)

By default (unless configured otherwise in your `terraform.tfvars`) once the deployment is done you should see something similar to above in your DCS+ Portal. There will be 1 bastion host (a jumphost VM for SSH access to the other VMs), 3 control plane VMs for the Kubernetes server nodes, and 3 worker VMs that are responsible for running your Kubernetes workload.

### Kubernetes-Dashboard
![DCS+ Dashboard](https://raw.githubusercontent.com/JamesClonk/terraform-vcloud-kubernetes/data/dcs_k8s_dashboard.png)

The Kubernetes dashboard will automatically be available to you after installation under [https://dashboard.my-kubernetes.my-domain.com](https://grafana.my-kubernetes.my-domain.com) (with *my-kubernetes.my-domain.com* being the value you configured in `terraform.tfvars -> k8s_domain_name`)

In order to login you will first need to request a temporary access token from your Kubernetes cluster:
```bash
$ kubectl -n kubernetes-dashboard create token kubernetes-dashboard
```
With this token you will be able to sign in into the dashboard.
> **Note**: This token is only valid temporarily, you will need request a new one each time it has expired.

### Grafana
![DCS+ Grafana](https://raw.githubusercontent.com/JamesClonk/terraform-vcloud-kubernetes/data/dcs_grafana.png)

The Grafana dashboard will automatically be available to you after installation under [https://grafana.my-kubernetes.my-domain.com](https://grafana.my-kubernetes.my-domain.com) (with *my-kubernetes.my-domain.com* being the value you configured in `terraform.tfvars -> k8s_domain_name`)

The username for accessing Grafana will be `admin` and the password can be retrieved from Kubernetes by running:
```bash
$ kubectl -n grafana get secret grafana -o jsonpath='{.data.admin-password}' | base64 -d; echo
```

### Longhorn
![DCS+ Grafana](https://raw.githubusercontent.com/JamesClonk/terraform-vcloud-kubernetes/data/dcs_k8s_longhorn.png)

To access the Longhorn dashboard you have to initialize a localhost port-forwarding towards the service on the cluster, since it is not exposed externally:
```bash
$ kubectl -n longhorn-system port-forward service/longhorn-frontend 9999:80
```
This will setup a port-forwarding for `localhost:9999` on your machine. Now you can open the Longhorn dashboard in your browser by going to [http://localhost:9999/#/dashboard](http://localhost:9999/).

### Cilium Hubble UI
![DCS+ Hubble](https://raw.githubusercontent.com/JamesClonk/terraform-vcloud-kubernetes/data/dcs_cilium_hubble.png)

The easiest way to access the Cilium Hubble UI is to download and install the [Cilium CLI](https://github.com/cilium/cilium-cli), and then simply run the following command:
```bash
$ cilium hubble ui
```
This will setup a port-forwarding in the background and open up a browser, pointing to the Hubble UI at [http://localhost:12000](http://localhost:12000).
