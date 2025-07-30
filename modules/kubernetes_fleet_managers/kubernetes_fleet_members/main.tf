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
  # On part de la map lokale qui contient fleet_managers et fleet_members
  # mais ici on génère la liste plate des membres avec la référence au fleet parent
  fleet_members = {
    for member in flatten([
      for fleet_key, fleet in local.kubernetes_fleet_managers.fleet_managers : [
        # On récupère les membres sous la clé 'members' dans chaque fleet manager
        for member_key, member in try(fleet.members, {}) : merge(
          member,
          {
            fleet_key = fleet_key   # référence au fleet manager parent
            member_key = member_key # éventuellement utile pour clé unique
          }
        )
      ]
    ]) : "${member.fleet_key}-${member.member_key}" => member
  }
}
