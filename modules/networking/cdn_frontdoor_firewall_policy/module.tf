resource "azurecaf_name" "cdn_frontdoor" {
  name          = var.settings.name
  resource_type = "azurerm_cdn_frontdoor_firewall_policy"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_cdn_frontdoor_firewall_policy" "cdn_frontdoor_firewall_policy" {
  name                              = azurecaf_name.cdn_frontdoor.result
  resource_group_name               = var.resource_group_name
  sku_name                          = var.settings.sku_name
  enabled                           = try(var.settings.enabled, null)
  mode                              = try(var.settings.mode, null)
  redirect_url                      = try(var.settings.redirect_url, null)
  custom_block_response_status_code = try(var.settings.custom_block_response_status_code, null)
  custom_block_response_body        = try(var.settings.custom_block_response_body, null)

  dynamic "custom_rule" {
    for_each = try(each.value.custom_rules, {})
    content {
      name                           = custom_rule.value.name
      enabled                        = try(custom_rule.value.enabled, null)
      priority                       = try(custom_rule.value.priority, null)
      rate_limit_duration_in_minutes = try(custom_rule.value.rate_limit_duration_in_minutes, null)
      rate_limit_threshold           = try(custom_rule.value.rate_limit_threshold, null)
      type                           = custom_rule.value.type
      action                         = custom_rule.value.action

      dynamic "match_condition" {
        for_each = try(custom_rule.value.match_conditions, {})
        content {
          match_variable     = match_condition.value.match_variable
          match_values       = match_condition.value.match_values
          operator           = match_condition.value.operator
          selector           = try(match_condition.value.selector, null)
          negation_condition = try(match_condition.value.negate_condition, null)
          transforms         = try(match_condition.value.transforms, null)
        }
      }
    }
  }

  dynamic "managed_rule" {
    for_each = try(each.value.managed_rules, {})
    content {
      type    = managed_rule.value.type
      version = managed_rule.value.version
      action  = managed_rule.value.action
      dynamic "exclusion" {
        for_each = try(managed_rule.value.exclusions, {})
        content {
          match_variable = exclusion.value.match_variable
          operator       = exclusion.value.operator
          selector       = exclusion.value.selector
        }
      }
      dynamic "override" {
        for_each = try(managed_rule.value.overrides, {})
        content {
          rule_group_name = override.value.rule_group_name
          dynamic "exclusion" {
            for_each = try(override.value.exclusions, {})
            content {
              match_variable = exclusion.value.match_variable
              operator       = exclusion.value.operator
              selector       = exclusion.value.selector
            }
          }
          dynamic "rule" {
            for_each = try(override.value.rules, {})
            content {
              rule_id = rule.value.rule_id
              action  = rule.value.action
              enabled = try(rule.value.enabled, null)
              dynamic "exclusion" {
                iterator = rule_exclusion
                for_each = try(rule.value.exclusions, {})
                content {
                  match_variable = rule_exclusion.value.match_variable
                  operator       = rule_exclusion.value.operator
                  selector       = rule_exclusion.value.selector
                }
              }
            }
          }
        }
      }
    }
  }
  tags = local.tags
}
