variable "proxmox_vms" {
  type = map(object({
    id = number

    name        = string
    vm_username = string
    vm_password = string

    ssh_public_key = optional(list(string), ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINRUe1B1ZMW7ZLA6YP0cI5ddsw/fZOZOAYBby698BV2H home"])
    ip             = string

    disk_datastore_id = string
    enable_efi = optional(bool, false)
    efi_disk = optional(string)

    gpu_passthrough = optional(bool, false)
    gpu_device      = optional(string, "hostpci0")
    gpu_pci_id      = optional(string, "0000:01:00")
    gpu_pcie        = optional(bool, true)
    gpu_rombar      = optional(bool, true)
    gpu_x_vga       = optional(bool, false)

    tags = optional(list(string), [])

    # Image source configuration - simplified to only "url" or "existing"
    image_source_type    = string           # "url" or "existing"
    image_filename       = optional(string) # Required if image_source_type = "url"
    image_url            = optional(string) # Required if image_source_type = "url"
    existing_file_path   = optional(string) # Required if image_source_type = "existing" (format: "local:iso/image.qcow2")
  }))
}

variable "proxmox_endpoint" {
  default = "https://192.168.0.101:8006/"
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
  default = "bravo"
  type    = string
}
variable "cpu_cores" {
  default = 1
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
