
output "id" {
  # depends_on = [azurerm_resource_group_template_deployment.asr]
  description = "The ID of the Recovery Plan."
  value       = azurerm_site_recovery_replication_recovery_plan.replication_plan.id
}

