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
  tags = merge(var.base_tags, local.module_tag, try(var.tags, null))

  # resource_groups = flatten(coalesce(
  #   try([
  #     for rg_key in try(var.settings.filter.resource_group_key, []) : 
  #       try(var.resource_groups[var.client_config.landingzone_key][rg_key], [])
  #     ], []),
  #   try([
  #     for rg_key in try(var.settings.filter.resource_group.key, []) : 
  #       try(var.resource_groups[var.client_config.landingzone_key][rg_key], [])
  #     ], []),
  #   []
  # ))

  # resource_groups = coalesce(
  #   try([
  #     for rg_key in try(var.settings.filter.resource_group_key, []) :
  #     try(var.resource_groups[var.client_config.landingzone_key][rg_key], var.resource_groups[var.settings.filter.lz_key][rg_key], [])
  #   ], []),
  #   try([
  #     for rg_key in try(var.settings.filter.resource_group.key, []) :
  #     try(var.resource_groups[var.client_config.landingzone_key][rg_key], var.resource_groups[var.settings.filter.lz_key][rg_key], [])
  #   ], []),
  #   []
  # )

  resource_groups = try(coalesce(
    try(var.settings.filter.resource_group_key, null),
    try(var.settings.filter.resource_group.key, null),
    try(var.resource_groups[var.client_config.landingzone_key][var.settings.filter.resource_group_key], null),
    try(var.resource_groups[var.client_config.landingzone_key][var.settings.filter.resource_group.key], null),
  ), null)
}
