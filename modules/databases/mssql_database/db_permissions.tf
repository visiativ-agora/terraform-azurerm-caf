data "azurerm_key_vault_secret" "sql_admin_password" {
  count        = try(var.settings.sql_users, null) == null ? 0 : 1
  name         = can(var.settings.keyvault_secret_name) ? var.settings.keyvault_secret_name : format("%s-password", var.mssql_servers[try(var.settings.lz_key, var.client_config.landingzone_key)][var.settings.mssql_server_key].name)
  key_vault_id = try(var.keyvault_id, null)
}

resource "null_resource" "set_db_permissions" {
  for_each = local.db_permissions

  triggers = {
    db_usernames = join(",", each.value.db_usernames)
    db_roles     = join(",", each.value.db_roles)
  }

  provisioner "local-exec" {
    command     = format("%s/scripts/set_db_permissions.sh", path.module)
    interpreter = ["/bin/bash"]
    on_failure  = fail

    environment = {
      SQLCMDSERVER = local.server_name
      SQLCMDDBNAME = azurerm_mssql_database.mssqldb.name
      DBADMINUSER  = var.mssql_servers[try(var.settings.lz_key, var.client_config.landingzone_key)][var.settings.mssql_server_key].administrator_login
      DBADMINPWD   = data.azurerm_key_vault_secret.sql_admin_password[0].value
      DBUSERNAMES  = format("'%s'", join(",", each.value.db_usernames))
      DBROLES      = format("'%s'", join(",", each.value.db_roles))
      SQLFILEPATH  = format("%s/scripts/set_db_permissions.sql", path.module)
    }
  }
}


# resource "null_resource" "delete_db_permissions" {
#   for_each = local.db_permissions

#   triggers = {
#     db_usernames = join(",", each.value.db_usernames)
#     sql_server_name    = local.server_name    
#     db_admin_user      = var.mssql_servers[try(var.settings.lz_key, var.client_config.landingzone_key)][var.settings.mssql_server_key].administrator_login
#     db_admin_password  = data.azurerm_key_vault_secret.sql_admin_password[0].value
#     sql_filepath = format("%s/scripts/delete_db_permissions.sql", path.module)
#   }

#   provisioner "local-exec" {
#     command     = format("%s/scripts/delete_db_permissions.sh", path.module)
#     interpreter = ["/bin/bash"]
#     on_failure  = fail

#     environment = {
#       SQLCMDSERVER = self.triggers.sql_server_name
#       DBADMINUSER  = self.triggers.db_admin_user
#       DBADMINPWD   = self.triggers.db_admin_password
#       DBUSERNAMES  = self.triggers.db_usernames
#       SQLFILEPATH  = self.triggers.sql_filepath
#     }
#   }
# }