terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.80.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpopint
  insecure = true # Only needed if your Proxmox server is using a self-signed certificate
}

resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.bootstrap_node_name
  file_name               = "talos-${var.talos_version}-nocloud-amd64.img"
  url                     = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/${var.talos_version}/nocloud-amd64.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each = var.proxmox_vms_talos
  vm_id = each.value.id
  name        = each.value.name
  description = "Managed by Terraform"
  tags        = each.value.tags
  node_name   = each.value.node_name
  on_boot     = true

  cpu {
    cores = each.value.cpu_cores
    type  = each.value.cpu_type
  }

  memory {
    dedicated = each.value.memory
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = each.value.bridge
  }
  boot_order = ["virtio0", "scsi0", "net0"]
  disk {
    datastore_id = var.datastore_id
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = each.value.disk_size
  }

  disk {
    datastore_id = "nvme0n1"
    interface    = "scsi0"
    ssd          = true
    size         = 30 # GB
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = var.datastore_id
    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = var.gateway
      }
    }
  }
}