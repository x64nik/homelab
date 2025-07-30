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
}