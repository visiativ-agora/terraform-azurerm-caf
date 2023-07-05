
module "maintenance_configuration" {
  source   = "./modules/maintenance_configuration"
  for_each = local.maintenance_configuration

  client_config       = local.client_config
  global_settings     = local.global_settings
  settings            = each.value
  name                = each.value.name
  location            = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name
  scope               = each.value.scope
  window              = try(each.value.window, null)
  install_patches     = try(each.value.install_patches, null)
  visibility          = try(each.value.visibility, null)
  properties          = try(each.value.properties, {})
  base_tags           = try(local.global_settings.inherit_tags, false) ? try(local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].tags, {}) : {}
  tags                = try(each.value.tags, {})
}

output "maintenance_configuration" {
  value = module.maintenance_configuration
}
