resource "azurerm_cdn_frontdoor_custom_domain" "cdn_frontdoor_custom_domain" {
  for_each = try({ for custom_domain in var.custom_domains : custom_domain.name => custom_domain }, {})

  name                     = coalesce(each.value.custom_resource_name, data.azurecaf_name.cdn_frontdoor_custom_domain[each.key].result)
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.cdn_frontdoor_profile.id
  dns_zone_id              = each.value.dns_zone_id
  host_name                = each.value.host_name

  dynamic "tls" {
    for_each = each.value.tls == null ? [] : ["enabled"]
    content {
      certificate_type        = each.value.tls.certificate_type
      minimum_tls_version     = each.value.tls.minimum_tls_version
      cdn_frontdoor_secret_id = try(each.value.tls.cdn_frontdoor_secret_id, null)
    }
  }
}