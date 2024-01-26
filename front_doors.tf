module "front_doors" {
  source   = "./modules/networking/front_door"
  for_each = local.networking.front_doors

  client_config       = local.client_config
  global_settings     = local.global_settings
  settings            = each.value
  name                = each.value.name
  resource_group_name = can(each.value.resource_group.name) ? each.value.resource_group.name : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name
  sku_name            = each.value.sku_name
  diagnostics         = local.combined_diagnostics
  base_tags           = try(local.global_settings.inherit_tags, false) ? try(local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].tags, {}) : {}
  tags                = try(each.value.tags, {})
}

output "front_doors" {
  value = module.front_doors
}