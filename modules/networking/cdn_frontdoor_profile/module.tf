resource "azurecaf_name" "cdn_frontdoor_profile" {
  name          = var.name
  resource_type = "azurerm_cdn_frontdoor_profile"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_cdn_frontdoor_profile" "cdn_frontdoor_profile" {
  name                     = azurecaf_name.cdn_frontdoor.result
  resource_group_name      = var.resource_group_name  
  sku_name                 = var.sku_name
  tags                     = local.tags

}
