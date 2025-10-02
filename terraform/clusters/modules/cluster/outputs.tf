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

output "bootstrap" {
  value = talos_machine_bootstrap.bootstrap
}

output "post_bootstrap_wait" {
  description = "Artificial delay after bootstrap to allow API server to stabilize"
  value       = time_sleep.wait_for_k8s
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = base64decode(local.kubeconfig_parsed.clusters[0].cluster["certificate-authority-data"])
}

output "client_certificate" {
  description = "Client certificate for authentication"
  value       = base64decode(local.kubeconfig_parsed.users[0].user["client-certificate-data"])
}

output "client_key" {
  description = "Client private key for authentication"
  value       = base64decode(local.kubeconfig_parsed.users[0].user["client-key-data"])
  sensitive   = true
}