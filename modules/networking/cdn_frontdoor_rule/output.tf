output "id" {
  value       = azurerm_cdn_frontdoor_rule.cdn_frontdoor_rule.id
  description = "The ID of the Front Door Rule."
}

output "cdn_frontdoor_rule_set_name" {
  value       = azurerm_cdn_frontdoor_rule.cdn_frontdoor_rule.cdn_frontdoor_rule_set_name
  description = "The name of the Front Door Rule Set containing this Front Door Rule."
}
