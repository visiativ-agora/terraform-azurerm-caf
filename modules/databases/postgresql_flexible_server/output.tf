output "id" {
  description = "ID of the PostgreSQL flexible server"
  value       = azurerm_postgresql_flexible_server.postgresql.id
}

output "location" {
  description = "Azure Region where the resource exists"
  value       = local.location
}

output "postgresql_flexible_server_administrator_username" {
  description = "Administrator username of PostgreSQL flexible server"
  value       = azurerm_postgresql_flexible_server.postgresql.administrator_login
  sensitive   = true
}

output "postgresql_flexible_server_administrator_password" {
  description = "Administrator password of PostgreSQL flexible server"
  value       = azurerm_postgresql_flexible_server.postgresql.administrator_password
  sensitive   = true
}

output "postgresql_flexible_server_id" {
  description = "ID of the PostgreSQL flexible server"
  value       = azurerm_postgresql_flexible_server.postgresql.id
}

output "postgresql_flexible_server_fqdn" {
  description = "FQDN of the PostgreSQL flexible server"
  value       = azurerm_postgresql_flexible_server.postgresql.fqdn
}

output "postgresql_flexible_server_name" {
  description = "Name of the PostgreSQL flexible server"
  value       = azurerm_postgresql_flexible_server.postgresql.name
}

output "postgresql_flexible_server_public_network_access_enabled" {
  description = "Is public network access enabled?"
  value       = azurerm_postgresql_flexible_server.postgresql.public_network_access_enabled
}

output "postgresql_flexible_server_configuration_id" {
  description = "ID of the PostgreSQL flexible server configuration"
  value = {
    for k, v in azurerm_postgresql_flexible_server_configuration.postgresql : k => v.id
  }
}

output "postgresql_flexible_server_database_id" {
  description = "ID of the PostgreSQL flexible server database"
  value = {
    for k, v in azurerm_postgresql_flexible_server_database.postgresql : k => v.id
  }
}

output "postgresql_flexible_server_firewall_rule_id" {
  description = "ID of the PostgreSQL flexible server firewall rule"
  value = {
    for k, v in azurerm_postgresql_flexible_server_firewall_rule.postgresql : k => v.id
  }
}

output "resource_group_name" {
  description = "Name of the Resource Group where the resource exists."
  value       = local.resource_group_name
}

# Output temporaire pour debug
output "debug_db_permissions_detailed" {
  value = {
    for db_key, db in try(var.settings.postgresql_databases, {}) : db_key => {
      db_name = db.name
      mi_configs = try(db.managed_identities.keys, [])
      
      # Test de chaque managed identity
      mi_tests = [
        for mi_config in try(db.managed_identities.keys, []) : {
          lz_key_resolved = try(mi_config.lz_key, try(mi_config.object_lz_key, var.client_config.landingzone_key))
          key_resolved    = try(mi_config.key, mi_config.object_key)
          role_type       = try(mi_config.role_type, "readwrite")
          
          # Test si l'objet existe
          can_access = can(var.remote_objects.managed_identities[try(mi_config.lz_key, try(mi_config.object_lz_key, var.client_config.landingzone_key))][try(mi_config.key, mi_config.object_key)])
          
          # Essayer d'accéder à l'objet
          mi_object = try(var.remote_objects.managed_identities[try(mi_config.lz_key, try(mi_config.object_lz_key, var.client_config.landingzone_key))][try(mi_config.key, mi_config.object_key)], "NOT FOUND")
        }
      ]
      
      # Liste finale des users
      users = local.db_permissions[db_key].users
    }
  }
  sensitive = false
}

output "debug_remote_objects_check" {
  value = {
    landingzone_key = var.client_config.landingzone_key
    
    # Vérifier si la landing zone existe
    has_lz = can(var.remote_objects.managed_identities["bbia_int_iam_rag"])
    
    # Lister les landing zones disponibles
    available_lz_keys = keys(var.remote_objects.managed_identities)
    
    # Vérifier si la MSI existe dans la landing zone spécifiée
    has_rag_in_target_lz = try(
      can(var.remote_objects.managed_identities["bbia_int_iam_rag"]["rag"]),
      "Landing zone not found"
    )
    
    # Essayer d'accéder directement
    direct_access = try(
      var.remote_objects.managed_identities["bbia_int_iam_rag"]["rag"],
      "Cannot access"
    )
  }
  sensitive = false
}
