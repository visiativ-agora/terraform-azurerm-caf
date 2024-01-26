resource "azurecaf_name" "cdn_frontdoor" {
  name          = var.settings.name
  resource_type = "azurerm_cdn_frontdoor_custom_domain"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_cdn_frontdoor_custom_domain" "cdn_frontdoor_custom_domain" {
  name                     = azurecaf_name.cdn_frontdoor.result
  cdn_frontdoor_profile_id = var.settings.cdn_frontdoor_profile_id
  host_name                = var.host_name
  dns_zone_id              = try(var.settings.dns_zone_id, null)


  tls {
      certificate_type        = try(tls.value.certificate_type, null)
      minimum_tls_version     = try(tls.value.minimum_tls_version, null)
      cdn_frontdoor_secret_id = try(tls.value.cdn_frontdoor_secret_id, null)
  }
}