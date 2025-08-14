terraform {
  required_providers {
    talos = {
      # https://registry.terraform.io/providers/siderolabs/talos/latest/docs
      source = "siderolabs/talos"
      version = "0.7.1"
    }
  }
}

locals {
  controller_vm_ips = [
    for key, node in var.proxmox_vms_talos : node.ip
    if node.controller == true
  ]
  worker_vm_ips = [
    for key, node in var.proxmox_vms_talos : node.ip
    if node.controller != true
  ]
  kubeconfig_parsed = yamldecode(talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw)
}

# Secrets required for Talos cluster
resource "talos_machine_secrets" "secrets" {}

# Client config
data "talos_client_configuration" "client" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.secrets.client_configuration
  endpoints            = local.controller_vm_ips
}

# Control Plane Configurations
data "talos_machine_configuration" "controlplanes" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${local.controller_vm_ips[0]}:6443"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.secrets.machine_secrets
  kubernetes_version = var.kubernetes_version
}

# Worker Configurations
data "talos_machine_configuration" "workers" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${local.controller_vm_ips[0]}:6443"
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.secrets.machine_secrets
  kubernetes_version = var.kubernetes_version
}

# Apply Control Plane Configurations
resource "talos_machine_configuration_apply" "controlplanes" {
  for_each = toset(local.controller_vm_ips)
  client_configuration        = talos_machine_secrets.secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplanes.machine_configuration
  node                        = each.value

  config_patches = [
    templatefile("${path.module}/templates/cpnetwork.yaml.tmpl", {
      cpip    = each.value
      gateway = var.default_gateway
      vip     = var.cp_vip
    }),
    file("${path.module}/templates/clusterconfig.yaml.tmpl")
  ]
}

# Apply Worker Configurations
resource "talos_machine_configuration_apply" "worker" {
  for_each = toset(local.worker_vm_ips)
  client_configuration        = talos_machine_secrets.secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.workers.machine_configuration
  node                        = each.value
  config_patches = [
    file("${path.module}/templates/clusterconfig.yaml.tmpl")
  ]
}

# Bootstrap cluster using the first control plane node
resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [ 
    talos_machine_configuration_apply.controlplanes,
    talos_machine_configuration_apply.worker
   ]
  client_configuration = talos_machine_secrets.secrets.client_configuration
  node                 = local.controller_vm_ips[0]
}

# Cluster health check
# data "talos_cluster_health" "health" {
#   depends_on = [
#     talos_machine_bootstrap.bootstrap,
#   ]
#   client_configuration = data.talos_client_configuration.client.client_configuration
#   control_plane_nodes  = local.controller_vm_ips
#   worker_nodes         = local.worker_vm_ips
#   endpoints            = data.talos_client_configuration.client.endpoints
# }

# Retrieve Kubeconfig
resource "talos_cluster_kubeconfig" "kubeconfig" {
  # depends_on           = [talos_machine_bootstrap.bootstrap, data.talos_cluster_health.health]
  client_configuration = talos_machine_secrets.secrets.client_configuration
  node                 = local.controller_vm_ips[0]
}