variable "proxmox_vms_talos" {
  type = map(object({
    id     = number
    ip     = string
    tags = list(string)

    node_name = optional(string, "alpha")
    bridge = optional(string, "vmbr0")

    # hardware
    cpu_cores = optional(number, 2)
    cpu_type = optional(string, "host")
    sockets = optional(number, 1)
    memory = optional(number, 4096)
    disk_size = optional(number, 20)

    # optional extra disk
    extra_disk = optional(object({
      enabled      = optional(bool, false)
      datastore_id = optional(string)
      interface    = optional(string, "scsi0")
      ssd          = optional(bool, true)
      size         = optional(number, 30)
    }))

    gpu_passthrough = optional(bool, false)
    gpu_device      = optional(string, "hostpci0")
    gpu_pci_id      = optional(string, "0000:01:00")
    gpu_pcie        = optional(bool, true)
    gpu_rombar      = optional(bool, true)
    gpu_x_vga       = optional(bool, false)

  })
  )
}

variable "proxmox_endpopint" {
  default = "https://192.168.0.101:8006/"
}

variable "bootstrap_node_name" {
  default = "ultron"
}

variable "gateway" {
  default = "192.168.0.1"
}

variable "talos_version" {
  default = "v1.11.5"
}

variable "talos_iso_sha" {
  default = "e3fab82b561b5e559cdf1c0b1e5950c0e52700b9208a2cfaa5b18454796f3a7e"
}

variable "datastore_id" {
  default = "local-lvm"
}
