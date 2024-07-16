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
  tags     = merge(var.base_tags, local.module_tag, try(var.tags, null))

#  resource_group = coalesce(
#     try(var.resource_groups[var.client_config.landingzone_key][var.settings.filter.resource_group_key], null),
#     try(var.resource_groups[var.settings.filter.resource_group.lz_key][var.settings.filter.resource_group.resource_group_key], null),
#     try(var.resource_groups[var.client_config.landingzone_key][var.settings.filter.resource_group.key], null),
#     try(var.resource_groups[var.settings.filter.resource_group.lz_key][var.settings.filter.resource_group.key], null)
#   )
  resource_groups = coalesce(
      flatten([
        for rg_key in var.settings.filter.resource_group_key : [
          try(var.resource_groups[var.client_config.landingzone_key][rg_key], []),
          try(var.resource_groups[var.settings.filter.resource_group.lz_key][rg_key], []),
          try(var.resource_groups[var.client_config.landingzone_key][rg_key], []),
          try(var.resource_groups[var.settings.filter.resource_group.lz_key][rg_key], [])
        ]
      ]),
      [] 
  )
}