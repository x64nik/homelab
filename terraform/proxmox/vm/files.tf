resource "proxmox_virtual_environment_download_file" "qcow2_img" {
  for_each     = var.proxmox_vms
  content_type = "iso"
  datastore_id = var.datastore_id
  node_name    = var.node_name
  url          = each.value.qcow2_img_url
  file_name    = each.value.qcow2_img_name
}
