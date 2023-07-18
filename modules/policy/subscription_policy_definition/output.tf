output "id" {
  description = "The ID of the Policy Definition"
  value       = azurerm_policy_definition.azurerm_policy_definition.id
}

output "role_definition_ids" {
  description = "A list of role definition id extracted from policy_rule required for remediation"
  value       = azurerm_subscription_policy_definition.subscription_policy_definition.role_definition_ids
}

