module "subscription_policy_definition" {
  source   = "./modules/policy/subscription_policy_definition"
  for_each = local.policy.subscription_policy_definition

  client_config   = local.client_config
  global_settings = local.global_settings
  settings            = each.value
  name                = each.value.name

  base_tags           = local.global_settings.inherit_tags
  resource_group      = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)]
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : null
  location            = try(local.global_settings.regions[each.value.region], null)


  mode = each.value.mode
  policy_type      = each.value.policy_type
  description = try(each.value.description, null)
  display_name = try(each.value.display_name, null)
  management_group_id = try(each.value.management_group_id, null)
  metadata = try(each.value.metadata, {})
  policy_rule = try(each.value.policy_rule, null)
  parameters = try(each.value.parameters, {})
}
output "subscription_policy_definition" {
  value = module.subscription_policy_definition
}
