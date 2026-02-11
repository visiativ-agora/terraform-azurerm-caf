

# # Créer les principals Entra ID et assigner les permissions
# resource "null_resource" "set_db_permissions" {
#   for_each = local.db_permissions

#   depends_on = [
#     azurerm_postgresql_flexible_server.postgresql,
#     azurerm_postgresql_flexible_server_database.postgresql
#   ]

#   triggers = {
#     db_name   = each.value.db_name
#     usernames = join(",", [for u in each.value.users : u.username if u.username != null])
#     roles     = join(",", [for u in each.value.users : u.role_type if u.username != null])
#     server_id = azurerm_postgresql_flexible_server.postgresql.id
#   }

#   provisioner "local-exec" {
#     command     = format("%s/scripts/set_db_permissions.sh", path.module)
#     interpreter = ["/bin/bash"]
#     on_failure  = fail

#     environment = {
#       PGHOST       = azurerm_postgresql_flexible_server.postgresql.fqdn
#       PGPORT       = "5432"
#       PGDATABASE   = each.value.db_name
#       PGADMINUSER  = var.settings.administrator_login
#       DBUSERNAMES  = join(",", [for u in each.value.users : u.username if u.username != null])
#       DBOBJECTIDS  = join(",", [for u in each.value.users : u.object_id if u.username != null])
#       DBROLES      = join(",", [for u in each.value.users : u.role_type if u.username != null])
#       CUSTOMGRANTS = join("|||", [for u in each.value.users : u.custom_grants if u.username != null])
#       SQLFILEPATH  = format("%s/scripts/set_db_permissions.sql", path.module)
#     }
#   }
# }

# # Créer les principals Entra ID et assigner les permissions
# resource "null_resource" "set_db_permissions" {
#   for_each = local.db_permissions

#   depends_on = [
#     azurerm_postgresql_flexible_server.postgresql,
#     azurerm_postgresql_flexible_server_database.postgresql,
#     azurerm_postgresql_flexible_server_active_directory_administrator.administrator
#   ]

#   triggers = {
#     db_name            = each.value.db_name
#     usernames          = join(",", [for u in each.value.users : u.username])
#     roles              = join(",", [for u in each.value.users : u.role_type])
#     object_ids         = join(",", [for u in each.value.users : u.object_id])
#     custom_grants      = join("|||", [for u in each.value.users : u.custom_grants])
#     server_id          = azurerm_postgresql_flexible_server.postgresql.id
#     ad_admin_principal = local.ad_admin != null ? local.ad_admin.principal_name : ""
#     ad_admin_type      = local.ad_admin_type != null ? local.ad_admin_type : ""
#   }

#   provisioner "local-exec" {
#     command     = format("%s/scripts/set_db_permissions.sh", path.module)
#     interpreter = ["/bin/bash"]
#     on_failure  = fail

#     environment = {
#       PGHOST          = azurerm_postgresql_flexible_server.postgresql.fqdn
#       PGPORT          = "5432"
#       PGDATABASE      = each.value.db_name
#       PGADMINUSER     = local.ad_admin != null ? local.ad_admin.principal_name : var.settings.administrator_login
#       PGADMINTYPE     = local.ad_admin_type != null ? local.ad_admin_type : ""
#       PGADMINOBJECTID = local.ad_admin_object_id != null ? local.ad_admin_object_id : ""
#       DBUSERNAMES     = join(",", [for u in each.value.users : u.username])
#       DBOBJECTIDS     = join(",", [for u in each.value.users : u.object_id])
#       DBROLES         = join(",", [for u in each.value.users : u.role_type])
#       CUSTOMGRANTS    = join("|||", [for u in each.value.users : u.custom_grants])
#       SQLFILEPATH     = format("%s/scripts/set_db_permissions.sql", path.module)
#     }
#   }
# }

