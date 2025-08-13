output "kube_config" {
  value = module.talos_cluster.kubeconfig
  sensitive = true
}

output "talos_config" {
  value     = module.talos_cluster.talosconfig 
  sensitive = true
}

output "kube_client_config" { 
  value = module.talos_cluster.kube_client_config 
  sensitive = true
}