resource "azurerm_cdn_frontdoor_endpoint" "cdn_frontdoor_endpoint" {
  for_each = try({ for endpoint in var.endpoints : endpoint.name => endpoint }, {})

  name                     = coalesce(each.value.custom_resource_name, data.azurecaf_name.cdn_frontdoor_endpoint[each.key].result)
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.cdn_frontdoor_profile.id

  enabled = each.value.enabled

  tags                = local.tags
}

