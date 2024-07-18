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

  filtered_resource_groups = try(flatten([
      for rg_key, rg_value in var.settings.filter.resources_groups : [
        for lz_key in rg_value.key :
        if try(var.resource_groups[rg_value.lz_key][lz_key], null) != null :
        var.resource_groups[rg_value.lz_key][lz_key]
      ]
    ]), [])
}

