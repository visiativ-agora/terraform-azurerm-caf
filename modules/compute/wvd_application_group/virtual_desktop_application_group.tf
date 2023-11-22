resource "azurecaf_name" "dag" {
  name          = var.settings.name
  resource_type = "azurerm_virtual_desktop_application_group"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_virtual_desktop_application_group" "dag" {
  name                         = azurecaf_name.dag.result
  location                     = local.location
  resource_group_name          = local.resource_group_name
  friendly_name                = try(var.settings.friendly_name, null)
  default_desktop_display_name = var.settings.type == "Desktop" ? try(var.settings.default_desktop_display_name, null) : null
  description                  = try(var.settings.description, null)
  type                         = var.settings.type
  host_pool_id                 = var.host_pool_id
  tags                         = merge(local.tags, try(var.settings.tags, null))
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "workspaceremoteapp" {
  workspace_id         = var.workspace_id
  application_group_id = azurerm_virtual_desktop_application_group.dag.id
}
