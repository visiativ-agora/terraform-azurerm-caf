resource "azurerm_cdn_frontdoor_route" "cdn_frontdoor_route" {
  for_each = try({ for route in var.routes : route.name => route }, {})

  name    = coalesce(each.value.custom_resource_name, data.azurecaf_name.cdn_frontdoor_route[each.key].result)
  enabled = each.value.enabled

  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.cdn_frontdoor_endpoint[each.value.endpoint_name].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.cdn_frontdoor_origin_group[each.value.origin_group_name].id

  cdn_frontdoor_origin_ids = local.origins_names_per_route[each.value.name]

  forwarding_protocol = each.value.forwarding_protocol
  patterns_to_match   = each.value.patterns_to_match
  supported_protocols = each.value.supported_protocols

  dynamic "cache" {
    for_each = each.value.cache == null ? [] : ["enabled"]
    content {
      query_string_caching_behavior = each.value.cache.query_string_caching_behavior
      query_strings                 = each.value.cache.query_strings
      compression_enabled           = each.value.cache.compression_enabled
      content_types_to_compress     = each.value.cache.content_types_to_compress
    }
  }

  cdn_frontdoor_custom_domain_ids = try(local.custom_domains_per_route[each.key], [])
  cdn_frontdoor_origin_path       = each.value.origin_path
  cdn_frontdoor_rule_set_ids      = try(local.rule_sets_per_route[each.key], [])

  https_redirect_enabled = each.value.https_redirect_enabled
  link_to_default_domain = each.value.link_to_default_domain
}

