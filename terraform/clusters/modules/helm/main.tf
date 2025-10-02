terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
  }
}

resource "helm_release" "chart" {
  for_each = { for chart in var.helm_charts : chart.name => chart }
  depends_on = [
    var.cluster_dependencies
  ]

  name             = each.value.name
  repository       = each.value.repository
  chart            = each.value.name
  namespace        = each.value.namespace
  create_namespace = each.value.create_namespace
  version          = each.value.version
  
  values = [file(each.value.values)]

 # These settings enable smooth upgrades
  timeout         = 600
  wait            = true
  wait_for_jobs   = true
  cleanup_on_fail = true
  max_history     = 5
  reuse_values    = true    # This is key for upgrades
  reset_values    = false   # This prevents value resets
  upgrade_install = true
}
