output "id" {
  value       = azurerm_eventgrid_system_topic.egt.id
  description = "The EventGrid System Topic ID."
}
output "identity" {
  value       = azurerm_eventgrid_system_topic.egt.identity
  description = "An `identity` block as defined below, which contains the Managed Service Identity information for this Event Grid System Topic."
}
