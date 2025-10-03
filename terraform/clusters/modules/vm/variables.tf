variable "proxmox_vms_talos" {
  type = map(object({
    id     = number
    ip     = string
    name = string
    controller = optional(bool)
    tags = list(string)

    node_name = optional(string, "alpha")
    bridge = optional(string, "vmbr0")


    # hardware
    cpu_cores = optional(number, 2)
    cpu_type = optional(string, "host")
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

  })
  )
}

variable "proxmox_endpopint" {
  default = "https://192.168.0.101:8006/"
}

variable "bootstrap_node_name" {
  default = "bravo"
}

variable "gateway" {
  default = "192.168.0.1"
}

variable "talos_version" {
  default = "v1.11.2"
}

variable "talos_iso_sha" {
  default = "613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245"
}

variable "datastore_id" {
  default = "local"
}
