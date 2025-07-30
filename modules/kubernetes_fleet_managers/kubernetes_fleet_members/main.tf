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
    for member in flatten([
      for fleet_key, fleet in try(var.kubernetes_fleet_managers, {}) : [
        for member_key, member in try(fleet.members, {}) : {
          fleet_key = fleet_key
          member_key = member_key
        }
      ]
    ]) : "${member.fleet_key}-${member.member_key}" => member
  }
}

