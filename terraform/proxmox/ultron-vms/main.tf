module "proxmox_vms" {
  source            = "../modules/vm"
  proxmox_vms_talos = var.proxmox_vms
  datastore_id      = "local-lvm"
}