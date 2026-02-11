locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = var.base_tags ? merge(
    var.global_settings.tags,
    try(var.resource_group.tags, null),
    local.module_tag,
    try(var.settings.tags, null)
    ) : merge(
    local.module_tag,
    try(var.settings.tags, null)
  )

  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  # Récupérer le premier administrateur AD configuré
  ad_admin = try(values(azurerm_postgresql_flexible_server_active_directory_administrator.administrator)[0], null)
  
  # Déterminer le type d'administrateur pour obtenir le bon token
  ad_admin_type = local.ad_admin != null ? local.ad_admin.principal_type : null
  
  # Récupérer l'object_id de l'administrateur
  ad_admin_object_id = local.ad_admin != null ? local.ad_admin.object_id : null

  # Flatten la structure des managed identities par database
  db_permissions = {
    for db_key, db in try(var.settings.postgresql_databases, {}) : db_key => {
      db_name = db.name
      users = compact(flatten(concat(
        # Managed Identities
        # La structure est: managed_identities = { keys = [ { lz_key = "...", key = "...", role_type = "..." } ] }
        [
          for mi_config in try(db.managed_identities.keys, []) :
          try(var.remote_objects.managed_identities[try(mi_config.lz_key, var.client_config.landingzone_key)][mi_config.key], null) != null ? {
            username      = var.remote_objects.managed_identities[try(mi_config.lz_key, var.client_config.landingzone_key)][mi_config.key].name
            object_id     = var.remote_objects.managed_identities[try(mi_config.lz_key, var.client_config.landingzone_key)][mi_config.key].principal_id
            role_type     = try(mi_config.role_type, "readwrite")
            custom_grants = try(mi_config.custom_grants, "")
          } : null
        ],
        # Azure AD Groups
        # La structure attendue: azuread_groups = { keys = [ { lz_key = "...", key = "...", role_type = "..." } ] }
        [
          for grp_config in try(db.azuread_groups.keys, []) :
          try(var.remote_objects.azuread_groups[try(grp_config.lz_key, var.client_config.landingzone_key)][grp_config.key], null) != null ? {
            username      = var.remote_objects.azuread_groups[try(grp_config.lz_key, var.client_config.landingzone_key)][grp_config.key].display_name
            object_id     = var.remote_objects.azuread_groups[try(grp_config.lz_key, var.client_config.landingzone_key)][grp_config.key].object_id
            role_type     = try(grp_config.role_type, "readwrite")
            custom_grants = try(grp_config.custom_grants, "")
          } : null
        ],
        # Azure AD Users
        # La structure attendue: azuread_users = { keys = [ { lz_key = "...", key = "...", role_type = "..." } ] }
        [
          for usr_config in try(db.azuread_users.keys, []) :
          try(var.remote_objects.azuread_users[try(usr_config.lz_key, var.client_config.landingzone_key)][usr_config.key], null) != null ? {
            username      = var.remote_objects.azuread_users[try(usr_config.lz_key, var.client_config.landingzone_key)][usr_config.key].user_principal_name
            object_id     = var.remote_objects.azuread_users[try(usr_config.lz_key, var.client_config.landingzone_key)][usr_config.key].object_id
            role_type     = try(usr_config.role_type, "readonly")
            custom_grants = try(usr_config.custom_grants, "")
          } : null
        ]
      )))
    } if (
      length(try(db.managed_identities.keys, [])) > 0 ||
      length(try(db.azuread_groups.keys, [])) > 0 ||
      length(try(db.azuread_users.keys, [])) > 0
    )
  }
}
