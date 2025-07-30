# Outputs
output "talosconfig" {
  value     = data.talos_client_configuration.client.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}