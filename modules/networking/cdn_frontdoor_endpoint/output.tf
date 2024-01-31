output "id" {
  value       = azurerm_cdn_frontdoor_endpoint.cdn_frontdoor_endpoint.id
  description = "The ID of this Front Door Endpoint."
}

output "host_name" {
  value       = azurerm_cdn_frontdoor_endpoint.cdn_frontdoor_endpoint.host_name
  description = "The host name of the Front Door."
}
