module "compute_instance" {
  source     = "./settings"
  depends_on = [azurerm_app_configuration.config]

  resource_group_name = local.resource_group_name
  config_settings     = local.config_settings
  keyvaults           = var.keyvaults
  app_config_id       = azurerm_app_configuration.config.id
  tags                = local.tags
  global_settings     = var.global_settings
  client_config       = var.client_config
  # key_names       = keys(local.config_settings)
  # key_values      = values(local.config_settings)
  # config_name     = azurecaf_name.app_config.result
}
