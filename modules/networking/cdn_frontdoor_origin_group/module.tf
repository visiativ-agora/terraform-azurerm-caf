resource "azurecaf_name" "cdn_frontdoor" {
  name          = var.settings.name
  resource_type = "azurerm_cdn_frontdoor_origin_group"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_cdn_frontdoor_origin_group" "cdn_frontdoor_origin_group" {
  name                                                        = azurecaf_name.cdn_frontdoor.result
  cdn_frontdoor_profile_id                                    = var.settings.cdn_frontdoor_profile_id
  session_affinity_enabled                                    = try(var.settings.session_affinity_enabled, null)
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes   = try(var.settings.restore_traffic_time_to_healed_or_new_endpoint_in_minutes, null)

  dynamic "health_probe" {
      for_each = try(each.value.health_probe, [])
      content {
        protocol            = each.value.health_probe.protocol
        interval_in_seconds = each.value.health_probe.interval_in_seconds
        path                = try(each.value.health_probe.path, null)
        request_type        = try(each.value.health_probe.request_type, null)
      }
    }
    
  load_balancing {
    additional_latency_in_milliseconds = each.value.load_balancing.additional_latency_in_milliseconds
    sample_size                        = each.value.load_balancing.sample_size
    successful_samples_required        = each.value.load_balancing.successful_samples_required
  }
}
