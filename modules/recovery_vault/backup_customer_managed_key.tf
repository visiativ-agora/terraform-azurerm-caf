resource "azurerm_data_protection_backup_vault_customer_managed_key" "backup_cmk" {
  for_each = try(var.settings.backup_data_encryption, {})

  data_protection_backup_vault_id = azurerm_recovery_services_vault.asr.id
  key_vault_key_id                = can(each.value.encryption_key) ? var.remote_objects.keyvault_keys[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.keyvault_key].id : null
}
