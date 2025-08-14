variable "cluster_ca_certificate" {
  type = string
}

variable "client_certificate" {
  type = string
}

variable "client_key" {
  type = string
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