output "id" {
  description = "The ID of the Cognitive Service Account."
  value       = azurerm_cognitive_account.service.id
}

output "deployment_id" {
  description = "The ID of the Deployment for Azure Cognitive Services Account."
  value       = azurerm_cognitive_account.deployment.id
}

output "endpoint" {
  description = "The endpoint used to connect to the Cognitive Service Account."
  value       = azurerm_cognitive_account.service.endpoint
}