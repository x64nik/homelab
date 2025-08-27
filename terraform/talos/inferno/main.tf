# Configure provider in root module
provider "helm" {
  kubernetes {
    host                   = "https://${var.cp_vip}:6443"
    cluster_ca_certificate = module.talos_cluster.cluster_ca_certificate
    client_certificate     = module.talos_cluster.client_certificate
    client_key            = module.talos_cluster.client_key
  }
}

provider "kubernetes" {
  host                   = "https://${var.cp_vip}:6443"
  cluster_ca_certificate = module.talos_cluster.cluster_ca_certificate
  client_certificate     = module.talos_cluster.client_certificate
  client_key            = module.talos_cluster.client_key
}

module "proxmox_vm" {
  source = "./modules/vm"
  proxmox_vms_talos = var.proxmox_vms_talos
}

module "talos_cluster" {
  source = "./modules/cluster"
  depends_on = [ module.proxmox_vm ]
  proxmox_vms_talos = var.proxmox_vms_talos
  default_gateway = var.default_gateway
  cp_vip = var.cp_vip
  cluster_name = var.cluster_name
  kubernetes_version = var.kubernetes_version
  cluster_dependencies = var.cluster_dependencies
  enable_mayastor = var.enable_mayastor
}

module "cilium" {
  source = "./modules/helm"
  depends_on = [
    module.talos_cluster.kubeconfig,
    module.talos_cluster.bootstrap
  ]

  controller_ip = var.cp_vip
  cluster_ca_certificate = module.talos_cluster.cluster_ca_certificate
  client_certificate     = module.talos_cluster.client_certificate
  client_key            = module.talos_cluster.client_key

  helm_charts = var.helm_charts
}

module "cilium_networking" {
  source = "./modules/cilium"
  depends_on = [
    module.cilium
  ]

  cluster_ca_certificate = module.talos_cluster.cluster_ca_certificate
  client_certificate     = module.talos_cluster.client_certificate
  client_key            = module.talos_cluster.client_key

  lb_ip_pools             = var.lb_ip_pools
  l2_announcement_policies = var.l2_announcement_policies
}