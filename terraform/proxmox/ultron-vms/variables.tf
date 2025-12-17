variable "datastore_id" {
  default = "local-lvm"
}

variable "proxmox_vms" {
  type = map(object({
    id   = number
    ip   = string
    tags = list(string)

    node_name = optional(string, "ultron")
    bridge    = optional(string, "vmbr0")

    # hardware
    cpu_cores = optional(number, 2)
    cpu_type  = optional(string, "host")
    sockets   = optional(number, 1)
    memory    = optional(number, 4096)
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
