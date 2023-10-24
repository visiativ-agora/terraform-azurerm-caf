terraform {
  required_providers {
    azurecaf = {
      source = "aztfmod/azurecaf"
    }
  }

}

locals {
  server_name = "${var.server_name}${var.cloud.sqlServerHostname}"

  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = merge(local.module_tag, try(var.settings.tags, null), var.base_tags)
  db_permissions = {
    for group_key, group in try(var.settings.db_permissions, {}) : group_key => {
      db_roles = group.db_roles
      db_usernames = flatten([
        for lz_key, value in group.managed_identities : [
          for managed_identity_key in value.managed_identity_keys : [var.managed_identities[lz_key][managed_identity_key].name]
        ]
      ])
    }
  }
}

data "azurerm_key_vault_secret" "sql_admin_password" {
  for_each = can(var.settings.sql_admin_password.keyvault_key) ? [1] : []

  name         = var.settings.sql_admin_password.keyvault_secret_name
  key_vault_id = var.keyvaults[try(var.settings.sql_admin_password.lz_key, local.client_config.landingzone_key)][var.settings.sql_admin_password.keyvault_key].id
}
