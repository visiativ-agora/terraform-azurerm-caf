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

  dynamic "install_patches" {
    for_each = var.scope == "InGuestPatch" ? [1] : []
    content {
      dynamic "linux" {
        for_each = try(var.install_patches.linux, null) != null ? [var.install_patches.linux] : []
        content {
          classifications_to_include    = lookup(linux.value.classifications_to_include, null)
          package_names_mask_to_exclude = lookup(linux.value.package_names_mask_to_exclude, null)
          package_names_mask_to_include = lookup(linux.value.package_names_mask_to_include, null)
        }
      }

      dynamic "windows" {
        for_each = try(var.install_patches.windows, null) != null ? [var.install_patches.windows] : []
        content {
          classifications_to_include = lookup(windows.value.classifications_to_include, null)
          kb_numbers_to_exclude      = lookup(windows.value.kb_numbers_to_exclude, null)
          kb_numbers_to_include      = lookup(windows.value.kb_numbers_to_include, null)
        }
      }

      reboot = lookup(var.install_patches.reboot, null)
    }
  }

  tags = var.tags
}
