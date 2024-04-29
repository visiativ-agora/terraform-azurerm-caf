
module "managed_identities" {
  source   = "./modules/security/managed_identity"
  for_each = var.managed_identities

  client_config       = local.client_config
  global_settings     = local.global_settings
  name                = each.value.name
  settings            = each.value
  location            = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name
  base_tags           = try(local.global_settings.inherit_tags, false) ? try(local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].tags, {}) : {}
}

output "managed_identities" {
  value = module.managed_identities
}

module "federated_identity_credential" {
  source   = "./modules/security/federated_identity_credential"
  for_each = var.federated_identity_credential

  client_config       = local.client_config
  global_settings     = local.global_settings  
  name                = each.value.name
  resource_group_name = module.managed_identities[each.key].resource_group_name
  parent_id           = module.managed_identities[each.key].id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = each.value.issuer
  subject             = each.value.sku_name
}

output "federated_identity_credential" {
  value = module.federated_identity_credential
}
