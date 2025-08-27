variable "cluster_dependencies" {
  description = "Cluster core dependencies without this cluster health checks may fail"
  type        = any
  default = []
}

variable "cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to install with Talos"
  type        = string
}

variable "default_gateway" {
  description = "Default network gateway for Talos nodes"
  type        = string
}

variable "cp_vip" {
  description = "Control plane virtual IP for Talos cluster"
  type        = string
}

variable "enable_mayastor" {
  description = "Enable Mayastor storage configuration"
  type        = bool
  default     = false
}

variable "proxmox_vms_talos" {
  type = map(object({
    id     = number
    ip     = string
    name = string
    controller = optional(bool)
    tags = list(string)
  }))
}