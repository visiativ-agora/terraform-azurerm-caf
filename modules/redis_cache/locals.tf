locals {
  redis_url = "rediss://:${azurerm_redis_cache.redis.primary_access_key}@${azurerm_redis_cache.redis.hostname}:${azurerm_redis_cache.redis.ssl_port}"

  redis_role_assignments_flat = {
    for role_name, role_data in try(var.redis_role_assignment, {}) :
    role_name => [
      for key in role_data.managed_identities.keys : {
        name      = "${role_name}-${key}-assignment"
        role_name = role_name

        lz_key = contains(keys(role_data.managed_identities), "lz_key") ? role_data.managed_identities.lz_key : var.client_config.landingzone_key

        principal_id = var.managed_identities[try(role_data.managed_identities.value.lz_key, var.client_config.landingzone_key)][key].principal_id
        alias        = var.managed_identities[try(role_data.managed_identities.value.lz_key, var.client_config.landingzone_key)][key].name
      }
    ]
  }

  redis_role_assignments_merged = flatten([for v in values(local.redis_role_assignments_flat) : v])  
}