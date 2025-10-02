terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

# CiliumLoadBalancerIPPool
resource "kubernetes_manifest" "cilium_lb_ip_pool" {
  for_each = var.lb_ip_pools

  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumLoadBalancerIPPool"
    
    metadata = {
      name = each.key
    }
    
    spec = {
      blocks = [
        for block in each.value.blocks : {
          cidr = block.cidr
          # Optional: add start and stop if needed
          start = lookup(block, "start", null)
          stop  = lookup(block, "stop", null)
        }
      ]
    }
  }
  
}

# CiliumL2AnnouncementPolicy
resource "kubernetes_manifest" "cilium_l2_announcement_policy" {
  for_each = var.l2_announcement_policies

  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumL2AnnouncementPolicy"
    
    metadata = {
      name = each.key
    }
    
    spec = {
      interfaces      = each.value.interfaces
      externalIPs     = each.value.external_ips
      loadBalancerIPs = each.value.load_balancer_ips
    }
  }
  
  depends_on = [kubernetes_manifest.cilium_lb_ip_pool]
}