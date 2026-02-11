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
  tags = var.base_tags ? merge(
    var.global_settings.tags,
    try(var.resource_group.tags, null),
    local.module_tag,
    try(var.settings.tags, null)
    ) : merge(
    local.module_tag,
    try(var.settings.tags,
    null)
  )

  location            = var.resource_group.location
  resource_group_name = var.resource_group.name


  db_permissions = {
    for db_key, db in try(var.settings.postgresql_databases, {}) : db_key => {
      db_name = db.name
      users = flatten(concat(
        # Managed Identities avec lz_key explicite
        [
          for lz_key, value in try(db.managed_identities, {}) : [
            for mi_config in try(value.keys, []) : {
              username      = try(var.remote_objects.managed_identities[try(mi_config.lz_key, lz_key)][mi_config.key].name, null)
              object_id     = try(var.remote_objects.managed_identities[try(mi_config.lz_key, lz_key)][mi_config.key].principal_id, null)
              role_type     = try(mi_config.role_type, "readwrite")
              custom_grants = try(mi_config.custom_grants, "")
            }
          ]
        ],
        # Azure AD Groups
        [
          for value in try(db.azuread_groups.keys, []) : {
            username      = try(var.remote_objects.azuread_groups[try(value.lz_key, var.client_config.landingzone_key)][value.key].display_name, null)
            object_id     = try(var.remote_objects.azuread_groups[try(value.lz_key, var.client_config.landingzone_key)][value.key].object_id, null)
            role_type     = try(value.role_type, "readwrite")
            custom_grants = try(value.custom_grants, "")
          }
        ],
        # Azure AD Users
        [
          for value in try(db.azuread_users.keys, []) : {
            username      = try(var.remote_objects.azuread_users[try(value.lz_key, var.client_config.landingzone_key)][value.key].user_principal_name, null)
            object_id     = try(var.remote_objects.azuread_users[try(value.lz_key, var.client_config.landingzone_key)][value.key].object_id, null)
            role_type     = try(value.role_type, "readonly")
            custom_grants = try(value.custom_grants, "")
          }
        ]
      ))
    } if length(try(db.managed_identities.keys, [])) > 0 || length(try(db.azuread_groups.keys, [])) > 0 || length(try(db.azuread_users.keys, [])) > 0
  }
}

