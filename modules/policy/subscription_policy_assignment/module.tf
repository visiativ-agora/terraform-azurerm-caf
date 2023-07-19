data "azurecaf_name" "subscription_policy_assignment" {
  name          = var.name
  resource_type = "azurerm_subscription_policy_assignment"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_subscription_policy_assignment" "subscription_policy_assignment" {
  name                 = data.azurecaf_name.subscription_policy_assignment.result
  policy_definition_id = var.policy_definition_id
  subscription_id      = var.subscription_id
  description          = try(var.description, null)
  display_name         = try(var.display_name, null)
  enforce              = try(var.enforce, null)
  location             = try(var.location, null)
  not_scopes           = try(var.not_scopes, null)
  parameters           = try(var.parameters, null)
  metadata             = try(var.metadata, null)

  dynamic "identity" {
    #for_each = var.settings.identity != null ? [var.settings.identity] : []
    for_each = lookup(var.settings, "identity", false) == false ? [] : [1]
    content {
      type         = try(identity.value.type, null)
      identity_ids = try(identity.value.identity_ids, [])
    }
  }

  dynamic "non_compliance_message" {
    #for_each = var.settings.non_compliance_message != null ? [var.settings.non_compliance_message] : []
    for_each = lookup(var.settings, "non_compliance_message", false) == false ? [] : [1]
    content {
      content                        = non_compliance_message.value.content
      policy_definition_reference_id = try(non_compliance_message.value.policy_definition_reference_id, null)
    }
  }

  dynamic "overrides" {
    #for_each = var.settings.overrides != null ? [var.settings.overrides] : []
    for_each = lookup(var.settings, "overrides", false) == false ? [] : [1]
    content {
      value = overrides.value.value
      dynamic "selectors" {
        for_each = var.settings.overrides.selectors != null ? [var.settings.overrides.selectors] : []
        content {
          in     = try(selectors.value.in, null)
          not_in = try(selectors.value.not_in, null)
        }
      }
    }
  }

  dynamic "resource_selectors" {
    #for_each = var.settings.resource_selectors != null ? [var.settings.resource_selectors] : []
    for_each = lookup(var.settings, "resource_selectors", false) == false ? [] : [1]
    content {
      name = resource_selectors.value.name
      dynamic "selectors" {
        for_each = var.settings.resource_selectors.selectors != null ? [var.settings.resource_selectors.selectors] : []
        content {
          kind   = selectors.value.kind
          in     = try(selectors.value.in, null)
          not_in = try(selectors.value.not_in, null)
        }
      }
    }
  }
}
