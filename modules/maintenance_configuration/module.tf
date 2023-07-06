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
  name                     = azurecaf_name.maintenance_configuration.result
  resource_group_name      = var.resource_group_name
  location                 = var.location
  scope                    = var.scope
  visibility               = try(var.visibility, null)
  properties               = try(var.properties, {})
  in_guest_user_patch_mode = try(var.in_guest_user_patch_mode, null)
  
  dynamic "window" {
    for_each = var.settings.window != null ? [var.settings.window] : []
    content {
      start_date_time      = window.value.start_date_time
      expiration_date_time = try(window.value.expiration_date_time, null)
      duration             = window.value.duration
      time_zone            = window.value.time_zone
      recur_every          = window.value.recur_every
    }
  }

  dynamic "install_patches" {   
    for_each = var.settings.scope == "InGuestPatch" && var.settings.install_patches != null ? [1] : []
    content {
      dynamic "linux" {
        for_each = try(var.install_patches.linux, null) != null ? [var.install_patches.linux] : []
        content {
          classifications_to_include    = toset(try(linux.value.classifications_to_include, []))
          package_names_mask_to_exclude = toset(try(linux.value.package_names_mask_to_exclude, []))
          package_names_mask_to_include = toset(try(linux.value.package_names_mask_to_include, []))
        }
      }

      dynamic "windows" {
        for_each = try(var.settings.install_patches.windows, null) != null ? [var.install_patches.windows] : []
        content {
          classifications_to_include = toset(try(windows.value.classifications_to_include, []))
          kb_numbers_to_exclude      = toset(try(windows.value.kb_numbers_to_exclude, []))
          kb_numbers_to_include      = toset(try(windows.value.kb_numbers_to_include, []))

        }
      }

      reboot = try(var.settings.install_patches.reboot, null)
    }
  }

  tags = var.tags
}
