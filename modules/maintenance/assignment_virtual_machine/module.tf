resource "azurerm_maintenance_assignment_virtual_machine" "maintenance_assignment_virtual_machine" {
  location                     = var.location
  maintenance_configuration_id = var.maintenance_configuration_id
  #virtual_machine_id           = var.virtual_machine_id
  virtual_machine_id = var.virtual_machine_id != null ? var.virtual_machine_id : can(each.value.virtual_machine_id) ? each.value.virtual_machine_id : try(local.combined_objects_virtual_machines[try(each.value.lz_key, local.client_config.landingzone_key)][each.value.virtual_machine_key].id, null)
}


