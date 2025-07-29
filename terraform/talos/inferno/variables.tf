variable "cluster_name" {
  type    = string
  default = "talos"
}

variable "default_gateway" {
  type    = string
  default = "192.168.0.1"
}

variable "talos_cp_01_ip_addr" {
  type    = string
  default = "<cp01 - an unused IP address in your network>"
}

variable "talos_cp_02_ip_addr" {
  type    = string
  default = "<cp02 - an unused IP address in your network>"
}

variable "talos_cp_03_ip_addr" {
  type    = string
  default = "<cp03 - an unused IP address in your network>"
}

variable "talos_worker_01_ip_addr" {
  type    = string
  default = "<worker01 - an unused IP address in your network>"
}

variable "talos_worker_02_ip_addr" {
  type    = string
  default = "<worker02 - an unused IP address in your network>"
}

variable "talos_worker_03_ip_addr" {
  type    = string
  default = "<worker03 - an unused IP address in your network>"
}

variable "cp_vip" {
  type    = string
  default = "192.168.0.21"
}

variable "talos_version" {
  type    = string
  default = "v1.9.5"
}

variable "talos_image_sha" {
  type    = string
  default = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
}

variable "kubernetes_version" {
  type    = string
  default = "1.33.0"
}