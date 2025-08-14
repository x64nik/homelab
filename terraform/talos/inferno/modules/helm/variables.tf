variable "cluster_ca_certificate" {
  type = string
}

variable "client_certificate" {
  type = string
}

variable "client_key" {
  type = string
}

variable "cluster_dependencies" {
  type = any
  default = []
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

variable "controller_ip" {
  type = string
}