resource "azurerm_site_recovery_replicated_vm" "vm_replication" {
  for_each = try(var.settings.replicated_vm.vms, {})
    
    name                          = each.value.name
    resource_group_name  = local.resource_group_name
    recovery_vault_name  = azurerm_recovery_services_vault.asr.name
    source_recovery_fabric_name = azurerm_site_recovery_fabric.recovery_fabric[each.value.source_recovery_fabric_key].name
    source_vm_id                              = azurerm_virtual_machine.vm.id
    recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.policy[each.value.policy_key].id
    source_recovery_protection_container_name = azurerm_site_recovery_protection_container.protection_container[each.value.source_protection_container_key].name

    target_resource_group_id                = azurerm_resource_group.[each.value.target_resource_group_key].id
    target_recovery_fabric_id               = azurerm_site_recovery_fabric.recovery_fabric[each.value.target_recovery_fabric_key].id
    target_recovery_protection_container_id = azurerm_site_recovery_protection_container.protection_container[each.value.target_protection_container_key].id

    target_availability_set_id             = try(each.value.target_availability_set_id, null)
    target_zone                            = try(each.value.target_zone, null)
    target_edge_zone                       = try(each.value.target_edge_zone, null)
    target_proximity_placement_group_id    = try(each.value.target_proximity_placement_group_id, null)
    target_boot_diagnostic_storage_account_id = try(each.value.target_boot_diagnostic_storage_account_id, null)
    target_capacity_reservation_group_id   = try(each.value.target_capacity_reservation_group_id, null)
    target_virtual_machine_scale_set_id    = try(each.value.target_virtual_machine_scale_set_id, null)
    target_network_id                      = try(each.value.target_network_id, null)
    test_network_id                        = try(each.value.test_network_id, null)
    multi_vm_group_name                    = try(each.value.multi_vm_group_name, null)

  dynamic "managed_disk" {
    for_each = var.settings.managed_disk != null ? [var.settings.managed_disk] : []

    content {
      disk_id =  managed_disk.value.disk_id
      staging_storage_account_id = managed_disk.value.staging_storage_account_id
      target_resource_group_id   = managed_disk.value.target_resource_group_id
      target_disk_type           = managed_disk.value.target_disk_type
      target_replica_disk_type   = managed_disk.value.target_replica_disk_type
      target_disk_encryption_set_id = try(managed_disk.value.target_disk_encryption_set_id, null)
      target_disk_encryption = try(managed_disk.value.target_disk_encryption, null)
    }
  }

  dynamic "unmanaged_disk" {
    for_each = try(var.settings.unmanaged_disk, [])

    content {
      disk_uri                  = unmanaged_disk.value.disk_uri
      staging_storage_account_id = unmanaged_disk.value.staging_storage_account_id
      target_storage_account_id = unmanaged_disk.value.target_storage_account_id
    }
  }

  dynamic "network_interface" {
    for_each = var.settings.network_interface != null ? [var.settings.network_interface] : []

    content {        
      source_network_interface_id   = network_interface.value.source_network_interface_id
      target_static_ip              = try(network_interface.value.target_static_ip, null)
      target_subnet_name            = try(network_interface.value.target_subnet_name, null)
      recovery_public_ip_address_id = try(network_interface.value.recovery_public_ip_address_id, null)
      failover_test_static_ip       = try(network_interface.value.failover_test_static_ip, null)
      failover_test_subnet_name     = try(network_interface.value.failover_test_subnet_name, null)
      failover_test_public_ip_address_id = try(network_interface.value.failover_test_public_ip_address_id, null)id
    }
  }

  dynamic "target_disk_encryption" {
    for_each = try(var.settings.target_disk_encryption, [])

    content {
      disk_encryption_key {
        secret_url = target_disk_encryption.value.disk_encryption_key.secret_url
        vault_id   = target_disk_encryption.value.disk_encryption_key.vault_id
      }

      key_encryption_key {
        key_url  = target_disk_encryption.value.key_encryption_key.key_url
        vault_id = target_disk_encryption.value.key_encryption_key.vault_id
      }
    }
  }
}