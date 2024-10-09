resource "azurerm_security_center_subscription_pricing" "pricing" {
  tier          = var.tier
  resource_type = var.resource_type
  # Api
  # AppServices
  # Arm
  # CloudPosture
  # ContainerRegistry
  # Containers
  # CosmosDbs
  # Dns
  # KeyVaults
  # KubernetesService
  # OpenSourceRelationalDatabases
  # SqlServers
  # SqlServerVirtualMachines
  # StorageAccounts
  # VirtualMachines

  dynamic "extension" {
    for_each = coalesce(var.extensions, {})
    content {
      name                            = each.value.name
      additional_extension_properties = try(each.value.additional_extension_properties, null)
    }
  }
}
