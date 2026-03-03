terraform {
  required_providers {
    azurecaf = {
      source = "aztfmod/azurecaf"
    }
    azapi = {
      source = "azure/azapi"
    }
  }
}

locals {
  server_name = "${var.server_name}${var.cloud.sqlServerHostname}"
  location    = var.location

  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = var.base_tags ? merge(
    var.global_settings.tags,
    try(var.resource_group.tags, null),
    try(var.settings.tags, null)
  ) : try(var.settings.tags, null)
  db_permissions = {
    for group_key, group in try(var.settings.db_permissions, {}) : group_key => {
      db_roles = group.db_roles

      db_usernames = distinct(compact(flatten(concat(
        [
          for mi_key, mi_value in try(group, {}) : [
            for k in try(mi_value.keys, []) :
            try(
              var.managed_identities[mi_value.lz_key][k].name,
              var.managed_identities[var.client_config.landingzone_key][k].name,
              null
            )
          ] if mi_key == "managed_identities"
        ],
        [
          for aad_key, aad_value in try(group, {}) : [
            for k in try(aad_value.keys, []) :
            try(
              var.azuread_groups[aad_value.lz_key][k].display_name,
              var.azuread_groups[var.client_config.landingzone_key][k].display_name,
              null
            )
          ] if aad_key == "azuread_groups"
        ]
      ))))
    }
  }
}
