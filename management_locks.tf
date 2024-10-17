locals {
  management_locks = flatten([
    for resource_type, resources in var.management_locks : [
      for resource in resources : merge(resource, {
        resource_type = resource_type,
      })
    ] if resource_type != "ids"
  ])
}

module "management_locks" {
  source   = "./modules/management_lock"
  for_each = local.management_locks

  global_settings = local.global_settings
  client_config   = local.client_config
  remote_objects  = local.remote_objects

  name            = each.name
  resource_type   = each.resource_type
  resource_lz_key = try(each.lz_key, var.client_config.landingzone_key)
  resource_key    = each.key
  level           = each.value.level
  notes           = try(each.value.notes, null)
}

module "management_locks_with_ids" {
  source   = "./modules/management_lock"
  for_each = try(var.management_locks.ids, {})

  global_settings = local.global_settings
  client_config   = local.client_config

  name        = each.value.name
  resource_id = each.value.id
  level       = each.value.level
  notes       = try(each.value.notes, null)
}
