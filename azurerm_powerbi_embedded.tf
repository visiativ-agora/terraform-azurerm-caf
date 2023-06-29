
module "azurerm_powerbi_embedded" {
  source   = "./modules/powerbi_embedded"
  for_each = local.powerbi_embedded.azurerm_powerbi_embedded

  client_config       = local.client_config
  global_settings     = local.global_settings
  settings            = each.value
  name                = each.value.name
  location            = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location
  resource_group_name = can(each.value.resource_group.name) ? each.value.resource_group.name : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name
  administrators      = each.value.administrators
  sku_name            = each.value.sku_name
  mode                = try(each.value.mode, "Gen1")
  tags                = try(each.value.tags, null)
}

# module "azurerm_powerbi_embedded" {
#   source = "./modules/powerbi_embedded"

#   name           = var.name
#   location       = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location
#   sku_name       = var.sku_name
#   administrators = var.administrators
#   mode           = try(var.mode, "Gen1")
#   tags           = try(var.tags, null)
# }


output "powerbi_embedded" {
  value = module.azurerm_powerbi_embedded
}