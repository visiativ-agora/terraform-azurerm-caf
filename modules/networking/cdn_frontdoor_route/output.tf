output "id" {
  value       = azurerm_cdn_frontdoor_profile.cdn.id
  description = "The ID of this Front Door Profile."
}
output "resource_guid" {
  value       = azurerm_cdn_frontdoor_profile.cdn.resource_guid
  description = "The UUID of this Front Door Profile which will be sent in the HTTP Header as the X-Azure-FDID attribute."
}
