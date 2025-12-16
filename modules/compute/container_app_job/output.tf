output "id" {
  value       = azurerm_container_app_job.caj.id
  description = "The ID of the Container App Job."
}

output "name" {
  value       = azurerm_container_app_job.caj.name
  description = "The name of the Container App Job."
}

output "outbound_ip_addresses" {
  value       = azurerm_container_app_job.caj.outbound_ip_addresses
  description = "A list of the Public IP Addresses which the Container App Job uses for outbound network access."
}

output "event_stream_endpoint" {
  value       = azurerm_container_app_job.caj.event_stream_endpoint
  description = "The endpoint for the Container App Job event stream."
}
