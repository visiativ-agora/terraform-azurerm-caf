resource "azurecaf_name" "cdn_frontdoor" {
  name          = var.settings.name
  resource_type = "azurerm_cdn_frontdoor_security_policy"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_cdn_frontdoor_security_policy" "cdn_frontdoor_security_policy" {
  name                              = azurecaf_name.cdn_frontdoor.result
  cdn_frontdoor_profile_id          = azurerm_cdn_frontdoor_profile.cdn_frontdoor_profile.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.cdn_frontdoor_firewall_policy.id
      association {        
        patterns_to_match = security_policies.value.patterns_to_match
        dynamic "domain" {
          for_each = try(domain.value.custom_domain_names, [])
          content {
            cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.cdn_frontdoor_custom_domain[domain.value].id
          }
        }
      }
    }
  }
}