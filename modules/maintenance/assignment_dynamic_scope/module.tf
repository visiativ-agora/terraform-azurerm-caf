resource "azurerm_maintenance_assignment_dynamic_scope" "maintenance_assignment_dynamic_scope" {
  name                         = var.name
  maintenance_configuration_id = var.maintenance_configuration_id

  dynamic "filter" {
    for_each = { for key, value in try(var.settings.filter.resource_group, {}) : key => value }
    content {
      locations = try(filter.value.locations, [])
      os_types  = try(filter.value.os_types, [])
      resource_groups = try(flatten([
        for key, value in var.resource_groups[filter.value.resource_group.key][try(filter.value.resource_group.lz_key, var.client_config.landingzone_key)] : value.id
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
