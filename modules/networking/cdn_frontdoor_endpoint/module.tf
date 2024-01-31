
resource "azurecaf_name" "cdn_frontdoor_endpoint" {
  name          = var.settings.name
  resource_type = "azurerm_cdn_frontdoor_endpoint"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_cdn_frontdoor_endpoint" "cdn_frontdoor_endpoint" {
  name                      = azurecaf_name.cdn_frontdoor_endpoint.result
  cdn_frontdoor_profile_id  = var.remote_objects.cdn_frontdoor_profile_id
  enabled = try(var.settings.enabled, null)
  tags = local.tags
}
