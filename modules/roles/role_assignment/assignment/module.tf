
resource "azurerm_role_assignment" "object_id" {
  for_each = {
    for key in lookup(var.keys, "object_ids", {}) : key => key
  }

  scope                = var.scope
  role_definition_name = try(var.role_definition_name, null)
  role_definition_id   = try(var.role_definition_id, null)
  principal_id         = each.value == "logged_in_user" || each.value == "logged_in_aad_app" ? var.client_config.object_id : each.value
  condition_version    = "2.0"
  condition            = try(each.value.condition, null)
}

resource "azurerm_role_assignment" "azuread_apps" {
  for_each = {
    for key in lookup(var.keys, "azuread_app_keys", {}) : key => key
  }

  scope                = var.scope
  role_definition_name = try(var.role_definition_name, null)
  role_definition_id   = try(var.role_definition_id, null)
  principal_id         = var.azuread_apps[each.key].azuread_service_principal.object_id
  condition_version    = "2.0"
  condition            = try(each.value.condition, null)
}

resource "azurerm_role_assignment" "azuread_group" {
  for_each = {
    for key in lookup(var.keys, "azuread_group_keys", {}) : key => key
  }

  scope                = var.scope
  role_definition_name = try(var.role_definition_name, null)
  role_definition_id   = try(var.role_definition_id, null)
  principal_id         = var.azuread_groups[each.key].id
  condition_version    = "2.0"
  condition            = try(each.value.condition, null)
}

resource "azurerm_role_assignment" "msi" {
  for_each = {
    for key in lookup(var.keys, "managed_identity_keys", {}) : key => key
  }

  scope                = var.scope
  role_definition_name = try(var.role_definition_name, null)
  role_definition_id   = try(var.role_definition_id, null)
  principal_id         = var.managed_identities[each.key].principal_id
  condition_version    = "2.0"
  condition            = try(each.value.condition, null)
}
