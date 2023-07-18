data "azurecaf_name" "subscription_policy_definition" {
  name          = var.name
  resource_type = "azurerm_subscription_policy_definition"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_policy_definition" "subscription_policy_definition" {
  name         = data.azurecaf_name.subscription_policy_definition.result
  policy_type  = var.policy_type
  mode         = var.mode
  display_name = try(var.display_name, null)
  description = try(var.description, null)
  management_group_id = try(var.management_group_id, null)
  metadata     = try(var.metadata, {})
  policy_rule  = try(var.policy_rule, null)
  parameters   = try(var.parameters, {})
}
