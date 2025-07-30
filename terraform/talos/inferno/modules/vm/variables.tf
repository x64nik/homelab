variable "proxmox_vms_talos" {
  type = map(object({
    id     = number
    ip     = string
    name = string
    controller = optional(bool)
    tags = list(string)
  }))
}

variable "gateway" {
  default = "192.168.0.1"
}

variable "talos_version" {
  default = "v1.9.5"
}

variable "node_name" {
    default = "alpha"
}
variable "cpu_cores" {
  default = 2
}
variable "cpu_type" {
  default = "host"
}
variable "memory" {
  default = 4096
}
variable "bridge" {
  default = "vmbr0"
}
variable "datastore_id" {
  default = "local"
}
variable "disk_size" {
  default = 20
}
