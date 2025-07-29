# master 01
resource "proxmox_virtual_environment_vm" "talos_cp_01" {
  name        = "inferno-cp-01"
  description = "Managed by Terraform"
  tags        = ["terraform", "inferno", "talos", "k8s", "control-plane"]
  node_name   = "alpha"
  on_boot     = true

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "sas_pool"
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 20
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = "sas_pool"
    ip_config {
      ipv4 {
        address = "${var.talos_cp_01_ip_addr}/24"
        gateway = var.default_gateway
      }
      #   ipv6 {
      #     address = "dhcp"
      #   }
    }
  }
}

# master 02
resource "proxmox_virtual_environment_vm" "talos_cp_02" {
  name        = "inferno-cp-02"
  description = "Managed by Terraform"
  tags        = ["terraform", "inferno", "talos", "k8s", "control-plane"]
  node_name   = "alpha"
  on_boot     = true

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "sas_pool"
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 20
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = "sas_pool"
    ip_config {
      ipv4 {
        address = "${var.talos_cp_02_ip_addr}/24"
        gateway = var.default_gateway
      }
      #   ipv6 {
      #     address = "dhcp"
      #   }
    }
  }
}

# master 03
resource "proxmox_virtual_environment_vm" "talos_cp_03" {
  name        = "inferno-cp-03"
  description = "Managed by Terraform"
  tags        = ["terraform", "inferno", "talos", "k8s", "control-plane"]
  node_name   = "alpha"
  on_boot     = true

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "sas_pool"
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 20
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = "sas_pool"
    ip_config {
      ipv4 {
        address = "${var.talos_cp_03_ip_addr}/24"
        gateway = var.default_gateway
      }
      #   ipv6 {
      #     address = "dhcp"
      #   }
    }
  }
}

# worker 01
resource "proxmox_virtual_environment_vm" "talos_worker_01" {
  depends_on  = [proxmox_virtual_environment_vm.talos_cp_01, proxmox_virtual_environment_vm.talos_cp_02, proxmox_virtual_environment_vm.talos_cp_03]
  name        = "inferno-worker-01"
  description = "Managed by Terraform"
  tags        = ["terraform", "inferno", "talos", "k8s", "worker"]
  node_name   = "alpha"
  on_boot     = true

  cpu {
    cores = 4
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "sas_pool"
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 20
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = "sas_pool"
    ip_config {
      ipv4 {
        address = "${var.talos_worker_01_ip_addr}/24"
        gateway = var.default_gateway
      }
      #   ipv6 {
      #     address = "dhcp"
      #   }
    }
  }
}

# worker 02
resource "proxmox_virtual_environment_vm" "talos_worker_02" {
  depends_on  = [proxmox_virtual_environment_vm.talos_cp_01, proxmox_virtual_environment_vm.talos_cp_02, proxmox_virtual_environment_vm.talos_cp_03]
  name        = "inferno-worker-02"
  description = "Managed by Terraform"
  tags        = ["terraform", "inferno", "talos", "k8s", "worker"]
  node_name   = "alpha"
  on_boot     = true

  cpu {
    cores = 4
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "sas_pool"
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 20
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = "sas_pool"
    ip_config {
      ipv4 {
        address = "${var.talos_worker_02_ip_addr}/24"
        gateway = var.default_gateway
      }
      #   ipv6 {
      #     address = "dhcp"
      #   }
    }
  }
}

# worker 03
resource "proxmox_virtual_environment_vm" "talos_worker_03" {
  depends_on  = [proxmox_virtual_environment_vm.talos_cp_01, proxmox_virtual_environment_vm.talos_cp_02, proxmox_virtual_environment_vm.talos_cp_03]
  name        = "inferno-worker-03"
  description = "Managed by Terraform"
  tags        = ["terraform", "inferno", "talos", "k8s", "worker"]
  node_name   = "alpha"
  on_boot     = true

  cpu {
    cores = 4
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "sas_pool"
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 20
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = "sas_pool"
    ip_config {
      ipv4 {
        address = "${var.talos_worker_03_ip_addr}/24"
        gateway = var.default_gateway
      }
      #   ipv6 {
      #     address = "dhcp"
      #   }
    }
  }
}