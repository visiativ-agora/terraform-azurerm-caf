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
  type      = "Microsoft.DataProtection/backupVaults@2024-04-01"
  name      = azurecaf_name.bckp.result
  location  = var.location
  parent_id = var.resource_group_id

  identity {
    type = try(var.settings.identity.type, "None")
    identity_ids = var.settings.identity.type == "UserAssigned" ? [
      var.managed_identities[try(var.settings.identity.lz_key, var.client_config.landingzone_key)][var.settings.identity.identity_key].id
    ] : null
  }

  body = jsonencode({
    properties = {
      featureSettings = {
        crossSubscriptionRestoreSettings = {
          state = try(var.settings.cross_subscription_restore_state, "Disabled")
        }
      }
      monitoringSettings = {
        azureMonitorAlertSettings = {
          alertsForAllJobFailures = try(var.settings.alerts_for_all_job_failures, "Disabled")
        }
      }
      replicatedRegions              = try(var.settings.replicated_regions, [])
      resourceGuardOperationRequests = try(var.settings.resource_guard_operation_requests, [])
      securitySettings = {

        encryptionSettings = try(var.settings.encryptionSettings, null) != null ? {
          infrastructureEncryption = var.settings.encryptionSettings.infrastructure_encryption_enabled ? "Enabled" : "Disabled"
          kekIdentity = {
            identityType = try(var.settings.identity.type, "SystemAssigned")
            identityId   = try(var.settings.identity.type, "SystemAssigned") == "UserAssigned" ? try(var.managed_identities[try(var.settings.identity.lz_key, var.client_config.landingzone_key)][var.settings.identity.identity_key].id, null) : null
          }
          keyVaultProperties = try(var.settings.encryptionSettings.backup_data_encryption.keyvault_key_key, null) != null ? {
            keyUri = var.remote_objects.keyvault_keys[try(var.settings.encryptionSettings.backup_data_encryption.lz_key, var.client_config.landingzone_key)][var.settings.encryptionSettings.backup_data_encryption.keyvault_key_key].id
          } : null
          state = var.settings.encryptionSettings.backup_data_encryption.encryption_state ? "Enabled" : "Disabled"
        } : null

        immutabilitySettings = {
          state = try(var.settings.immutability_state, "Disabled")
        }

        softDeleteSettings = {
          state                   = try(var.settings.softdelete.state, "Off")
          retentionDurationInDays = try(var.settings.softdelete.days, 0)
        }
      }
      storageSettings = [
        {
          datastoreType = var.settings.datastore_type
          type          = var.settings.redundancy
        }
      ]
    }
  })

  tags = local.tags
}

