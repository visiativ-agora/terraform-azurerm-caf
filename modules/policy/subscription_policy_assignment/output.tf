output "id" {
  description = "The ID of the Subscription Policy Assignment"
  value       = azurerm_subscription_policy_assignment.azurerm_subscription_policy_assignment.id
}

output "identity" {
  description = "The identity of the Policy Assignment for this Subscription."
  value       = azurerm_subscription_policy_assignment.azurerm_subscription_policy_assignment.identity
}

