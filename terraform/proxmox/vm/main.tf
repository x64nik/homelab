terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.80.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://192.168.0.100:8006/"
  insecure = true # Only needed if your Proxmox server is using a self-signed certificate
}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each    = var.proxmox_vms
  vm_id       = each.value.id
  name        = each.value.name
  description = "Managed by Terraform"
  tags        = each.value.tags
  node_name   = var.node_name
  on_boot     = true
  machine = "q35"
  bios = "ovmf"

  efi_disk {
    datastore_id = each.value.disk_datastore_id
  }

  cpu {
    cores = var.cpu_cores
    type  = var.cpu_type
  }

  memory {
    dedicated = var.memory
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = var.bridge
  }

  disk {
    datastore_id = each.value.disk_datastore_id
    file_id      = proxmox_virtual_environment_download_file.qcow2_img[each.key].id
    interface    = "scsi0"
    size         = var.disk_size
  }

  operating_system {
    type = "l26"
  }

  initialization {
    interface = "scsi1"
    datastore_id = each.value.disk_datastore_id
    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = var.gateway
      }
    }

    user_account {
      keys     = each.value.ssh_public_key
      password = each.value.vm_password
      username = each.value.vm_username
    }
    # user_data_file_id = proxmox_virtual_environment_file.qcow2_img.id
  }
  dynamic "hostpci" {
    for_each = lookup(each.value, "gpu_passthrough", false) ? [1] : []
    content {
      device = lookup(each.value, "gpu_device", "hostpci0")
      id     = lookup(each.value, "gpu_pci_id", "0000:01:00")
      pcie   = lookup(each.value, "gpu_pcie", true)
      rombar = lookup(each.value, "gpu_rombar", true)
      xvga   = lookup(each.value, "gpu_x_vga", false)
    }
  }
}