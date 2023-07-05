resource "azurecaf_name" "maintenance_configuration" {
  name          = var.name
  resource_type = "azurerm_maintenance_configuration"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_maintenance_configuration" "maintenance_configuration" {
  name                = azurecaf_name.maintenance_configuration.result
  resource_group_name = var.resource_group_name
  location            = var.location
  scope               = var.scope
  visibility          = try(var.visibility, null)
  properties          = try(var.properties, {})

  dynamic "window" {
    for_each = try(var.window, null) != null ? [1] : []
    content {
      start_date_time      = lookup(window.value.start_date_time, null)
      expiration_date_time = lookup(window.value.expiration_date_time, null)
      duration             = lookup(window.value.duration, null)
      time_zone            = lookup(window.value.time_zone, null)
      recur_every          = lookup(window.value.recur_every, null)
    }
  }

  tags = var.tags
}
