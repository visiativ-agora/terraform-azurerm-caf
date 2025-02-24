# naming convention
resource "azurecaf_name" "bckp" {

  name          = var.settings.backup_vault_name
  resource_type = "azurerm_data_protection_backup_vault"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

# resource "azurerm_data_protection_backup_vault" "backup_vault" {
#   name                = azurecaf_name.bckp.result
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   datastore_type      = var.settings.datastore_type
#   redundancy          = var.settings.redundancy
#   tags                = local.tags

#   dynamic "identity" {
#     for_each = lookup(var.settings, "enable_identity", false) == false ? [] : [1]

#     content {
#       type = "SystemAssigned"
#     }
#   }
# }

resource "azapi_resource" "backup_vault" {
  type      = "Microsoft.DataProtection/backupVaults@2024-10-01"
  name      = azurecaf_name.bckp.result
  location  = var.location
  parent_id = var.resource_group_id

  body = jsonencode({
    properties = {
      storageSettings = [
        {
          datastoreType = var.settings.datastore_type
          type          = var.settings.redundancy
        }
      ]
      securitySettings = {
        encryptionSettings = {
          infrastructureEncryption = try(var.settings.infrastructure_encryption_enabled, false) ? "Enabled" : "Disabled"
          kekIdentity = try(var.settings.kek_identity_id, null) != null && try(var.settings.kek_identity_type, null) != null ? {
            identityId   = var.settings.kek_identity_id
            identityType = var.settings.kek_identity_type
          } : null
          keyVaultProperties = {
            keyUri = can(var.settings.backup_data_encryption.encryption_key) ? var.remote_objects.keyvault_keys[try(var.settings.backup_data_encryption.lz_key, var.client_config.landingzone_key)][var.settings.backup_data_encryption.keyvault_key_key].id : null
          }
          state = try(var.settings.backup_data_encryption.encryption_state, "Disabled")
        }
        softDeleteSettings = {
          state                   = try(var.settings.soft_delete_retention_days, null) != null ? "Enabled" : "Disabled"
          retentionDurationInDays = try(var.settings.soft_delete_retention_days, 14)
        }
      }
      monitoringSettings = try(var.settings.alerts_for_all_job_failures, null) != null ? {
        azureMonitorAlertSettings = {
          alertsForAllJobFailures = var.settings.alerts_for_all_job_failures
        }
      } : null
      featureSettings = try(var.settings.cross_region_restore_state, null) != null ? {
        crossRegionRestoreSettings = {
          state = var.settings.cross_region_restore_state
        }
      } : null
    }
  })

  tags = local.tags

  dynamic "identity" {
    for_each = lookup(var.settings, "enable_identity", false) == false ? [] : [1]

    content {
      type = "SystemAssigned"
    }
  }
}


