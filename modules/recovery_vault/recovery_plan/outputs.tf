
output "id" {
  # depends_on = [azurerm_resource_group_template_deployment.asr]
  description = "The ID of the Site Recovery Fabric."
  value       = azurerm_recovery_services_vault.asr.id
}

