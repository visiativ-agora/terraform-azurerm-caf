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
  description = try(var.description, null)
  display_name = try(var.display_name, null)
  enforce = try(var.enforce, null)
  identity = try(var.identity, [])
  location = try(var.location, null)
  metadata = try(var.metadata, {})
  non_compliance_message = try(var.non_compliance_message, [])
  not_scopes = try(var.not_scopes, null)
  parameters = try(var.parameters, {})
  overrides = try(var.overrides, [])
  resource_selectors = try(var.resource_selectors, [])

}
