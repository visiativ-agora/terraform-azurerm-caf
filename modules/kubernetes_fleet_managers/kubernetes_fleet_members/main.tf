terraform {
  required_providers {
    azurecaf = {
      source = "aztfmod/azurecaf"
    }
  }

}

locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  # tags = merge(var.base_tags, local.module_tag, try(var.tags, null))
  # location            = var.location
  # resource_group_name = var.resource_group_name
}


locals {
  fleet_members = {
    for item in flatten([
      for fleet_key, fleet in var.kubernetes_fleet_managers : [
        for member_key, member in try(fleet.members, {}) : [
          for cluster in member.keys : {
            fleet_key         = fleet_key
            fleet_name        = fleet.name
            fleet_resource_group_key = try(fleet.resource_group_key, "")
            fleet_tags        = try(fleet.tags, {})
            member_key        = member_key
            member_name       = member.name
            cluster_lz_key    = cluster.lz_key
            cluster_name      = cluster.keys
          }
        ]
      ]
    ]) :
    "${item.fleet_key}-${item.member_key}-${item.cluster_lz_key}" => item
  }
}

