output "id" {
  value       = azurerm_linux_web_app.linux_app_services.id
  description = "The ID of the App Service."
}
output "default_hostname" {
  value       = azurerm_linux_web_app.linux_app_services.default_hostname 
  description = "The Default Hostname associated with the Linux Web App"
}
output "outbound_ip_addresses" {
  value       = azurerm_linux_web_app.linux_app_services.outbound_ip_addresses
  description = "A comma separated list of outbound IP addresses"
}
output "possible_outbound_ip_addresses" {
  value       = azurerm_linux_web_app.linux_app_services.possible_outbound_ip_addresses
  description = "A comma separated list of outbound IP addresses. not all of which are necessarily in use"
}
output "identity" {
  value       = try(azurerm_linux_web_app.linux_app_services.identity.0.principal_id, null)
  description = "The identity id of the linux web app."
}