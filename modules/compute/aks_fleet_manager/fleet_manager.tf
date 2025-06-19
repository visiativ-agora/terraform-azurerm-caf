data "azurecaf_name" "kfm" {
  name          = var.settings.name
  resource_type = "azurerm_fleetManager"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_kubernetes_fleet_manager" "kfm" {
  name                = data.azurecaf_name.kfm.result
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
