
module "kubernetes_fleet_managers" {
  source   = "./modules/kubernetes_fleet_managers/kubernetes_fleet_managers"
  for_each = local.kubernetes_fleet_managers.kubernetes_fleet_managers

  client_config       = local.client_config
  global_settings     = local.global_settings
  settings            = each.value
  location            = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name

  base_tags           = try(local.global_settings.inherit_tags, false) ? try(local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].tags, {}) : {}
  tags                = try(each.value.tags, {})
}

output "kubernetes_fleet_managers" {
  value = module.kubernetes_fleet_managers
}

module "kubernetes_fleet_members" {
  source   = "./modules/kubernetes_fleet_managers/kubernetes_fleet_members"
  depends_on = [module.kubernetes_fleet_managers]
  for_each = local.kubernetes_fleet_managers.kubernetes_fleet_members

  client_config         = local.client_config
  global_settings       = local.global_settings
  settings              = each.value.members
  kubernetes_cluster_id = local.combined_objects_kubernetes_fleet_managers
  kubernetes_fleet_id   = module.kubernetes_fleet_managers[each.key].id

  members = flatten([
    for group in try(each.value.members, {}) : [
      for item in group.value.keys : {
        lz_key = item.lz_key
        keys   = item.keys
      }
    ]
  ])
}

output "kubernetes_fleet_members" {
  value = module.kubernetes_fleet_members
}
