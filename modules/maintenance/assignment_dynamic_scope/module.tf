resource "azurerm_maintenance_assignment_dynamic_scope" "maintenance_assignment_dynamic_scope" {
  name                         = var.name
  maintenance_configuration_id = var.maintenance_configuration_id

  filter {
    locations = try(var.settings.locations, [])
    os_types  = try(var.settings.os_types, [])
    # resource_groups = try(flatten(
    #   [
    #   for key, value in var.resource_groups[try(var.settings.resource_group.lz_key, var.client_config.landingzone_key)][var.settings.resource_group.key].name
    #   ]
    # ), [])

  #   resource_groups = flatten(
  #   [
  #     for key, value in try(var.resource_groups, {}) : [
  #       can(value.id) ? value.id : var.resource_groups[try(value.lz_key, var.client_config.landingzone_key)][value.key]
  #     ]
  #   ]
  # )

      resource_groups = try(flatten([
        for key, value in var.resource_groups[try(var.settings.filter.lz_key, var.client_config.landingzone_key)] : value.name
        if contains(var.settings.filter.resource_groups_keys, key)
        ]), [])


    resource_types = try(var.settings.filter.resource_types, [])
    tag_filter     = try(var.settings.filter.tag_filter, null)

    dynamic "tags" {
      for_each = {
        for key, value in try(var.settings.filter.tags, {}) : key => value
      }

      content {
        tag    = tags.value.tag
        values = tags.value.values
      }
    }
  }
}

#   filter {
#     locations = try(var.settings.filter.locations, [])
#     os_types  = try(var.settings.filter.os_types, [])


#     resource_groups = local.resource_groups

#     # resource_groups = var.resource_groups


#     resource_types = try(var.settings.filter.resource_types, [])
#     tag_filter     = try(var.settings.filter.tag_filter, null)

#     dynamic "tags" {
#       for_each = {
#         for key, value in try(var.settings.filter.tags, {}) : key => value
#       }

#       content {
#         tag    = tags.value.tag
#         values = tags.value.values
#       }
#     }
#   }
# }
