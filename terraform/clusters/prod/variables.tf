variable "proxmox_vms_talos" {
  type = map(object({
    id     = number
    ip     = string
    name = string
    controller = optional(bool)
    tags = list(string)

    node_name = optional(string, "bravo")
    bridge = optional(string, "vmbr0")


    # hardware
    cpu_cores = optional(number, 1)
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

variable "helm_charts" {
  description = "List of Helm charts to deploy"
  type = list(object({
    name             = string
    repository       = string
    version          = string
    namespace        = string
    create_namespace = optional(bool, true)
    values           = string
  }))
  default = []
}

variable "lb_ip_pools" {
  description = "Map of LoadBalancer IP pools"
  type = map(object({
    blocks = list(object({
      cidr  = string
      start = optional(string)
      stop  = optional(string)
    }))
  }))
  default = {}
}

variable "l2_announcement_policies" {
  description = "Map of L2 announcement policies"
  type = map(object({
    interfaces          = list(string)
    external_ips        = bool
    load_balancer_ips   = bool
  }))
  default = {}
}

variable "cilium_ready" {
  description = "Dependency to ensure Cilium is ready"
  type        = any
  default     = null
}