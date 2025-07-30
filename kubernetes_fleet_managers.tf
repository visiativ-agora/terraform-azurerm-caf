
module "kubernetes_fleet_managers" {
  source   = "./modules/kubernetes_fleet_managers/kubernetes_fleet_managers"
  for_each = local.kubernetes_fleet_managers.fleet_managers

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

  for_each = local.kubernetes_fleet_managers.fleet_members

  kubernetes_fleet_id   = module.kubernetes_fleet_managers[each.value.fleet_key].id
  kubernetes_cluster_id = local.combined_objects_aks_clusters[each.value.cluster_name].id

  client_config   = local.client_config
  global_settings = local.global_settings

  settings = {
    member_name         = each.value.member_name
    cluster_lz_key      = each.value.cluster_lz_key
    fleet_resource_group_key = each.value.fleet_resource_group_key
    fleet_tags          = each.value.fleet_tags
    # autres settings spécifiques si besoin
  }
}

output "kubernetes_fleet_members" {
  value = module.kubernetes_fleet_members
}

