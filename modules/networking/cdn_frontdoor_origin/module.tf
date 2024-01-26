resource "azurecaf_name" "cdn_frontdoor" {
  name          = var.settings.name
  resource_type = "azurerm_cdn_frontdoor_origin"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_cdn_frontdoor_origin" "cdn_frontdoor_origin" {
  name = azurecaf_name.cdn_frontdoor.result
  cdn_frontdoor_origin_group_id   = var.settings.cdn_frontdoor_origin_group_id
  enabled                         = try(var.settings.enabled, null)
  certificate_name_check_enabled  = try(var.settings.certificate_name_check_enabled, null)
  host_name                       = try(var.settings.host_name, null)
  http_port                       = try(var.settings.http_port, null)
  https_port                      = try(var.settings.https_port, null)
  origin_host_header              = try(var.settings.origin_host_header, null)
  priority                        = try(var.settings.priority, null)
  weight                          = try(var.settings.weight, null)

  dynamic "private_link" {
    for_each = try(each.value.private_link, [])    
    content {
      request_message        = each.value.private_link.request_message
      target_type            = each.value.private_link.target_type
      location               = each.value.private_link.location
      private_link_target_id = each.value.private_link.private_link_target_id
    }
  }
}
