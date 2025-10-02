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
  default = "v1.9.5"
}

variable "datastore_id" {
  default = "local"
}
