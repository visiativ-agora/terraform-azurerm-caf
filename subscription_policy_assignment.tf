module "subscription_policy_assignment" {
  source   = "./modules/policy/subscription_policy_assignment"
  for_each = local.policy.subscription_policy_assignment

  client_config   = local.client_config
  global_settings = local.global_settings
  settings            = each.value
  name                = each.value.name

  base_tags           = local.global_settings.inherit_tags
  location            = try(local.global_settings.regions[each.value.region], null)


  policy_definition_id = module.subscription_policy_definition[each.key].id
  subscription_id      = each.value.subscription_id
  description = try(each.value.description, null)
  display_name = try(each.value.display_name, null)
  enforce = try(each.value.enforce, null)
  identity = try(each.value.identity, null)  
  metadata = try(each.value.metadata, null)
  non_compliance_message = try(each.value.non_compliance_message, null)
  not_scopes = try(each.value.not_scopes, null)
  parameters = try(each.value.parameters, null)
  overrides = try(each.value.overrides, null)
  resource_selectors = try(each.value.resource_selectors, null)
}
output "subscription_policy_assignment" {
  value = module.subscription_policy_assignment
}