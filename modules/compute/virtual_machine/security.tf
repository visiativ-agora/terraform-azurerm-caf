module "vulnerability_assessment" {
  for_each = var.settings.security.enable_vulnerability_assessment ? var.settings.virtual_machine_settings : {}

  source             = "../../security/security_center/server_vulnerability_assessment"
  virtual_machine_id = try(azurerm_virtual_machine.vm.id, azurerm_windows_virtual_machine.vm.id, azurerm_linux_virtual_machine.vm.id)
}


module "advanced_threat_protection" {
  source      = "../../security/security_center/advanced_threat_protection"
  resource_id = try(azurerm_virtual_machine.vm.id, azurerm_windows_virtual_machine.vm.id, azurerm_linux_virtual_machine.vm.id)
  enabled     = try(var.settings.security.enable_advanced_threat_protection, false)
}
