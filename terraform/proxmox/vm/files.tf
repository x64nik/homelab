# Download files from URL (only for VMs that specify a URL)
resource "proxmox_virtual_environment_download_file" "qcow2_img" {
  for_each = {
    for k, v in var.proxmox_vms : k => v
    if v.image_source_type == "url" && v.image_url != null
  }

  content_type = "iso"
  datastore_id = each.value.disk_datastore_id
  node_name    = var.node_name
  
  url       = each.value.image_url
  file_name = each.value.image_filename
  overwrite = true
}