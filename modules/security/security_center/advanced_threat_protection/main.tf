resource "azurerm_advanced_threat_protection" "atp" {
  target_resource_id = var.resource_id
  enabled            = var.enabled
}
