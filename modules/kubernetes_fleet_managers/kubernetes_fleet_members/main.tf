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
  fleet_members = flatten([
    for fleet_key, fleet in aks_fleet_managers : [
      for group_key, group in try(fleet.members_groups, {}) : [
        for member_key, member in try(group.members, {}) : {
          fleet_key  = fleet_key
          fleet_name = fleet.name
          group_key  = group_key
          member_key = member_key
          lz_key     = member.lz_key
          key        = member.key
          name       = try(member.name, member_key)
        }
      ]
    ]
  ])
}

