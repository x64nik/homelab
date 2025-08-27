# outputs.tf

# Output individual VM SSH configs
output "vm_ssh_configs" {
  description = "SSH configuration entries for each VM"
  value = {
    for vm_key, vm in proxmox_virtual_environment_vm.vm : vm_key => {
      host = vm.name
      hostname = split("/", var.proxmox_vms[vm_key].ip)[0]  # Extract IP without CIDR
      user = var.proxmox_vms[vm_key].vm_username
      port = 22
      vm_id = vm.vm_id
    }
  }
}

# Output formatted SSH config ready for ~/.ssh/config
output "ssh_config_entries" {
  description = "Formatted SSH config entries ready to copy to ~/.ssh/config"
  value = join("\n\n", [
    for vm_key, vm in proxmox_virtual_environment_vm.vm : 
    "Host ${vm.name}\n    HostName ${split("/", var.proxmox_vms[vm_key].ip)[0]}\n    User ${var.proxmox_vms[vm_key].vm_username}\n    Port 22\n    IdentityFile ${var.ssh_private_key_path}"
  ])
}

# Output as a single block for easy copying
output "complete_ssh_config" {
  description = "Complete SSH config block for all VMs"
  value = <<-EOT
# Talos VMs SSH Configuration
# Add this to your ~/.ssh/config file

${join("\n\n", [
  for vm_key, vm in proxmox_virtual_environment_vm.vm : 
  "Host ${vm.name}\n    HostName ${split("/", var.proxmox_vms[vm_key].ip)[0]}\n    User ${var.proxmox_vms[vm_key].vm_username}\n    Port 22\n    IdentityFile ${var.ssh_private_key_path}"
])}

# End of Talos VMs Configuration
EOT
}

# Output just the connection commands for quick reference
output "ssh_connection_commands" {
  description = "SSH connection commands for each VM"
  value = {
    for vm_key, vm in proxmox_virtual_environment_vm.vm : 
    vm.name => "ssh ${var.proxmox_vms[vm_key].vm_username}@${split("/", var.proxmox_vms[vm_key].ip)[0]}"
  }
}

# Output VM details for reference
output "vm_details" {
  description = "Created VM details"
  value = {
    for vm_key, vm in proxmox_virtual_environment_vm.vm : vm_key => {
      name = vm.name
      vm_id = vm.vm_id
      node_name = vm.node_name
      ip_address = split("/", var.proxmox_vms[vm_key].ip)[0]
      tags = vm.tags
    }
  }
}