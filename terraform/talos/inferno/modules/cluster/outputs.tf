# Outputs
output "talosconfig" {
  value     = data.talos_client_configuration.client.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}

output "kube_client_config" { 
  value = talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration  
  sensitive = true
}