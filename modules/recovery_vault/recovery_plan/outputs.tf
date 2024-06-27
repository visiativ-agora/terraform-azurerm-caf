output "id" {
  description = "The IDs of the Recovery Plans."
  value = { for k, v in azurerm_site_recovery_replication_recovery_plan.replication_plan : k => v.id }
}
