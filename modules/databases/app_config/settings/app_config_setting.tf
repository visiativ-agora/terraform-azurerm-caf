# resource "azurecaf_name" "settings" {
#   name          = format("app-config-%s", var.config_name)
#   resource_type = "azurerm_template_deployment"
#   prefixes      = var.global_settings.prefixes
#   random_length = var.global_settings.random_length
#   clean_input   = true
#   passthrough   = var.global_settings.passthrough
#   use_slug      = var.global_settings.use_slug
# }

# # create app config settings
# resource "azurerm_resource_group_template_deployment" "settings" {
#   name                = "settings"
#   resource_group_name = var.resource_group_name

#   template_content = file(local.arm_filename)

#   parameters_content = jsonencode(local.parameters_content)

#   deployment_mode = "Incremental"

#   timeouts {
#     create = "1h"
#     update = "1h"
#     delete = "1h"
#     read   = "5m"
#   }
# }

resource "azurerm_app_configuration_key" "config" {
  for_each = var.config_settings

  configuration_store_id = var.app_config_id
  key                    = each.value.key
  label                  = try(each.value.label, null)
  # if value is a keyvault reference, set the correct type, set value to null and set vault_key_reference
  type                = try(each.value.vault_key, null) == null ? "kv" : "vault"
  value               = try(each.value.vault_key, null) == null ? each.value.value : null
  vault_key_reference = try(each.value.vault_key, null) == null ? null : "${var.keyvaults[try(each.value.vault_key.keyvault.lz_key, var.client_config.landingzone_key)][each.value.vault_key.keyvault.key].vault_uri}secrets/${each.value.vault_key.secret_name}"
}
