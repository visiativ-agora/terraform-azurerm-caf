resource "azurerm_site_recovery_replicated_vm" "replication" {
  count = try(var.settings.replication, null) == null ? 0 : 1

  name                = "${var.settings.replication.name}-vm-replication"
  resource_group_name = coalesce(
    try(var.settings.replication.recovery_vault_rg, null),
    try(split("/", var.settings.replication.recovery_vault_id)[4], null),
    try(var.recovery_vaults[var.client_config.landingzone_key][var.settings.replication.vault_key].resource_group_name, null),
    try(var.recovery_vaults[var.settings.replication.lz_key][var.settings.replication.vault_key].resource_group_name, null)
  )
  recovery_vault_name = coalesce(
    try(var.settings.replication.recovery_vault_name, null),
    try(split("/", var.settings.replication.recovery_vault_id)[8], null),
    try(var.recovery_vaults[var.client_config.landingzone_key][var.settings.replication.vault_key].name, null),
    try(var.recovery_vaults[var.settings.replication.lz_key][var.settings.replication.vault_key].name, null)
  )
  recovery_replication_policy_id = coalesce(
    try(var.settings.replication.replication_policy_id, null),
    try(var.recovery_vaults[var.client_config.landingzone_key][var.settings.replication.vault_key].replication_policies[var.settings.replication.policy_key].id, null),
    try(var.recovery_vaults[var.settings.replication.lz_key][var.settings.replication.vault_key].replication_policies[var.settings.replication.policy_key].id, null)
  )
  source_recovery_fabric_name = coalesce(
    try(var.settings.replication.source.recovery_fabric_name, null),
    try(var.recovery_vaults[var.client_config.landingzone_key][var.settings.replication.vault_key].recovery_fabrics[var.settings.replication.source.recovery_fabric_key].name, null),
    try(var.recovery_vaults[var.settings.replication.lz_key][var.settings.replication.vault_key].recovery_fabrics[var.settings.replication.source.recovery_fabric_key].name, null)
  )
  source_vm_id = local.os_type == "linux" ? try(azurerm_linux_virtual_machine.vm["linux"].id, null) : try(azurerm_windows_virtual_machine.vm["windows"].id, null)
  source_recovery_protection_container_name = coalesce(
    try(var.settings.replication.source.protection_container_name, null),
    try(var.recovery_vaults[var.client_config.landingzone_key][var.settings.replication.vault_key].protection_containers[var.settings.replication.source.protection_container_key].name, null),
    try(var.recovery_vaults[var.settings.replication.lz_key][var.settings.replication.vault_key].protection_containers[var.settings.replication.source.protection_container_key].name, null)
  )
  target_resource_group_id = coalesce(
    try(var.resource_groups[var.client_config.landingzone_key][var.settings.replication.target.resource_group_key].id, null),
    try(var.recovery_vaults[var.settings.replication.target.resource_group.lz_key][var.settings.replication.resource_group.key].id, null)
  )

  target_recovery_fabric_id = coalesce(
    try(var.settings.replication.target.recovery_fabric_id, null),
    try(var.recovery_vaults[var.client_config.landingzone_key][var.settings.replication.vault_key].recovery_fabrics[var.settings.replication.target.recovery_fabric_key].id, null),
    try(var.recovery_vaults[var.settings.replication.lz_key][var.settings.replication.vault_key].recovery_fabrics[var.settings.replication.target.recovery_fabric_key].id, null)
  )
  target_recovery_protection_container_id = coalesce(
    try(var.settings.replication.source.protection_container_id, null),
    try(var.recovery_vaults[var.client_config.landingzone_key][var.settings.replication.vault_key].protection_containers[var.settings.replication.target.protection_container_key].id, null),
    try(var.recovery_vaults[var.settings.replication.lz_key][var.settings.replication.vault_key].protection_containers[var.settings.replication.target.protection_container_key].id, null)
  )
  target_zone = try(var.settings.replication.target.zone, "")
}