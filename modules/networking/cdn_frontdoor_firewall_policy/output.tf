output "id" {
  value       = azurerm_cdn_frontdoor_firewall_policy.cdn_frontdoor_firewall_policy.id
  description = "The ID of the Front Door Firewall Policy."
}

output "frontend_endpoint_ids" {
  value       = azurerm_cdn_frontdoor_firewall_policy.cdn_frontdoor_firewall_policy.frontend_endpoint_ids
  description = "The Front Door Profiles frontend endpoints associated with this Front Door Firewall Policy."
}