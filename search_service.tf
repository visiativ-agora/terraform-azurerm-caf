module "search_service" {
  source   = "./modules/search_service"
  for_each = local.search_services.search_services

  client_config       = local.client_config
  global_settings     = local.global_settings
  resource_group      = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)]
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : null
  location            = lookup(each.value, "region", null) == null ? local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location : local.global_settings.regions[each.value.region]
  settings            = each.value
  base_tags           = local.global_settings.inherit_tags
  identity            = try(each.value.identity, null)
  private_endpoints   = try(each.value.private_endpoints, {})
  private_dns         = local.combined_objects_private_dns
  vnets               = local.combined_objects_networking
  virtual_subnets     = local.combined_objects_virtual_subnets
}

output "search_service" {
  value = module.search_service
}

module "search_shared_private_link_service" {
  depends_on = [module.search_service]
  source     = "./modules/search_service/private_link"
  for_each   = local.search_services.search_services

  client_config     = local.client_config
  global_settings   = local.global_settings
  settings          = each.value.shared_private_access
  search_service_id = module.search_service[each.value.search_service.key].id
  target_resource_id = {
    "storage" = local.combined_objects_storage_accounts[
      try(each.value.shared_private_access.target_resource.lz_key, local.client_config.landingzone_key)
    ][each.value.shared_private_access.target_resource.key].id
    "cosmosdb" = local.combined_objects_cosmosdb_sql_databases[
      try(each.value.shared_private_access.target_resource.lz_key, local.client_config.landingzone_key)
    ][each.value.shared_private_access.target_resource.key].id
  }[each.value.shared_private_access.target_resource.type]
}

output "search_shared_private_link_service" {
  value = module.search_shared_private_link_service
}