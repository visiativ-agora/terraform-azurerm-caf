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
      db_usernames = flatten([
        for lz_key, value in group.managed_identities : [
          for managed_identity_key in value.managed_identity_keys : [var.managed_identities[lz_key][managed_identity_key].name]
        ]
        [for mi_key, mi_value in group : [
          for value in try(mi_value.keys, mi_value.managed_identity_keys, []) : [
            try(var.managed_identities[mi_value.lz_key][value].name, var.managed_identities[var.client_config.landingzone_key][value].name)
          ]
        ] if mi_key == "managed_identities"],
        [for mi_key, mi_value in group : [
          for value in mi_value.keys : [
            try(var.azuread_groups[mi_value.lz_key][value].display_name, var.azuread_groups[var.client_config.landingzone_key][value].display_name)
          ]
        ] if mi_key == "azuread_groups"]
      ])
    }
  }
}
