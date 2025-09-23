resource "azurecaf_name" "cdn_frontdoor_profile" {
  name          = var.settings.name
  resource_type = "azurerm_cdn_frontdoor_profile"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_cdn_frontdoor_profile" "cdn_frontdoor_profile" {
  name                     = azurecaf_name.cdn_frontdoor_profile.result
  resource_group_name      = local.resource_group_name
  sku_name                 = var.settings.sku_name
  response_timeout_seconds = try(var.settings.response_timeout_seconds, null)

  # dynamic "identity" {
  #   for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]

  #   content {
  #     type         = var.settings.identity.type
  #     identity_ids = contains(["userassigned", "systemassigned", "systemassigned, userassigned"], lower(var.settings.identity.type)) ? local.managed_identities : null
  #   }
  # }

  tags = merge(local.tags, try(var.settings.tags, null))

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}


locals {
  system_assigned = contains(
    [lower(try(var.settings.identity.type, ""))],
    "systemassigned"
  )
}


resource "null_resource" "assign_identity_to_frontdoor" {
  depends_on = [azurerm_cdn_frontdoor_profile.cdn_frontdoor_profile]
  for_each = try(var.settings.identity, null) == null ? {} : { "identity" = var.settings.identity }
  # count = contains(keys(var.settings), "identity") && var.settings.identity != null ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
      az afd profile identity assign --resource-group ${local.resource_group_name} --profile-name ${azurecaf_name.cdn_frontdoor_profile.result} ${local.system_assigned ? "--mi-system-assigned" : ""} ${length(local.managed_identities) > 0 ? "--mi-user-assigned ${join(" ", local.managed_identities)}" : ""}
    EOT
  }
}