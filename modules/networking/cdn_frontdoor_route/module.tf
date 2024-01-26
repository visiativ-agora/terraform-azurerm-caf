resource "azurecaf_name" "cdn_frontdoor" {
  name          = var.settings.name
  resource_type = "azurerm_cdn_frontdoor_route"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_cdn_frontdoor_route" "cdn_frontdoor_route" {
  name                          = azurecaf_name.cdn_frontdoor.result
  enabled                       = try(var.settings.enabled, null)

  cdn_frontdoor_endpoint_id     = var.settings.cdn_frontdoor_endpoint_id
  cdn_frontdoor_origin_group_id = var.settings.cdn_frontdoor_origin_group_id
  cdn_frontdoor_origin_ids      = var.settings.cdn_frontdoor_origin_ids
  cdn_frontdoor_rule_set_ids    = var.settings.cdn_frontdoor_rule_set_ids

  forwarding_protocol           = try(var.settings.forwarding_protocol, null)
  patterns_to_match             = var.settings.patterns_to_match
  supported_protocols           = var.settings.supported_protocols

  dynamic "cache" {
    for_each = try(var.settings.cache, null) != null ? [var.settings.cache] : {}
    content {
      query_string_caching_behavior = try(cache.value.query_string_caching_behavior, null)
      query_strings                 = try(cache.value.query_strings, null)
      compression_enabled           = try(cache.value.compression_enabled, null)
      content_types_to_compress     = try(cache.value.content_types_to_compress, null)
    }
  }

  cdn_frontdoor_custom_domain_ids = try(azurerm_cdn_frontdoor_custom_domain.cdn_frontdoor_custom_domain.custom_domains_per_route[each.key], [])
  cdn_frontdoor_origin_path       = try(var.settings.cdn_frontdoor_origin_path, null)

  https_redirect_enabled = try(var.settings.https_redirect_enabled, null)
  link_to_default_domain = try(var.settings.link_to_default_domain, null)
}