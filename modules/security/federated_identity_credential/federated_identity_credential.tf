resource "azurecaf_name" "fic" {
  name          = var.name
  resource_type = "federated_identity_credential"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "federated_identity_credential" "fic" {
  name                = data.azurecaf_name.fic.result
  resource_group_name = var.resource_group_name
  audience            = var.audience
  issuer              = var.issuer
  parent_id           = module.managed_identities[each.value.managed_identity_key].id
  subject             = var.subject != null ? var.subject : 

}
