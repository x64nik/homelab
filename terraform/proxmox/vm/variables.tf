variable "proxmox_vms" {
  type = map(object({
    id = number

    name        = string
    vm_username = string
    vm_password = string

    ssh_public_key = optional(list(string), [])
    ip             = string

    disk_datastore_id = string

    gpu_passthrough = optional(bool, false)
    gpu_device      = optional(string, "hostpci0")
    gpu_pci_id      = optional(string, "0000:01:00")
    gpu_pcie        = optional(bool, true)
    gpu_rombar      = optional(bool, true)
    gpu_x_vga       = optional(bool, false)

    qcow2_img_url  = string
    qcow2_img_name = string

    tags = optional(list(string), [])

  }))
}

variable "proxmox_endpoint" {
  default = "https://192.168.0.100:8006/"
  type    = string
}

variable "ssh_private_key_path" {
  default = "~/.ssh/config.d/homelab/home"
  type    = string
}

variable "gateway" {
  default = "192.168.0.1"
  type    = string
}

variable "node_name" {
  default = "alpha"
  type    = string
}
variable "cpu_cores" {
  default = 2
  type    = number
}
variable "cpu_type" {
  default = "host"
  type    = string
}
variable "memory" {
  default = 4096
  type    = number
}
variable "bridge" {
  default = "vmbr0"
  type    = string
}
variable "datastore_id" {
  default = "local"
  type    = string
}
variable "disk_size" {
  default = 20
  type    = number
}
