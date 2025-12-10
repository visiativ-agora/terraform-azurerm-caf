# resource "azurerm_federated_identity_credential" "fed_cred" {
#   provider = try(var.settings.provider, null)
  
#   name                = var.settings.name
#   resource_group_name = coalesce(try(var.settings.resource_group.name, null), try(var.resource_group_name, null), try(var.resource_group.name, null))
#   audience            = try(var.settings.audience, ["api://AzureADTokenExchange"])
#   parent_id           = coalesce(try(var.settings.managed_identity.id, null), var.managed_identities[try(var.settings.managed_identity.lz_key, var.client_config.landingzone_key)][var.settings.managed_identity.key].id)
#   subject             = var.settings.subject
#   issuer              = coalesce(try(var.oidc_issuer_url, null), try(var.settings.oidc_issuer_url, null))
# }


resource "azurerm_federated_identity_credential" "fed_cred" {
  name                = var.settings.name
  resource_group_name = coalesce(
    try(var.settings.managed_identity.resource_group_name, null),
    try(var.settings.resource_group.name, null), 
    var.resource_group_name
  )
  audience            = try(var.settings.audience, ["api://AzureADTokenExchange"])
  
  # Parent ID avec ordre de priorité correct
  parent_id = coalesce(
    # 1. ID complet fourni explicitement (priorité maximale)
    try(var.settings.managed_identity.id, null),
    
    # 2. Construction cross-subscription si subscription_id est fourni
    try(var.settings.managed_identity.subscription_id, null) != null ? format(
      "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.ManagedIdentity/userAssignedIdentities/%s",
      var.settings.managed_identity.subscription_id,
      coalesce(try(var.settings.managed_identity.resource_group_name, null), var.resource_group_name),
      var.settings.managed_identity.name
    ) : null,
    
    # 3. Référence depuis var.managed_identities (fallback pour compatibilité)
    try(var.managed_identities[try(var.settings.managed_identity.lz_key, var.client_config.landingzone_key)][var.settings.managed_identity.key].id, null)
  )
  
  subject = var.settings.subject
  issuer  = coalesce(try(var.oidc_issuer_url, null), try(var.settings.oidc_issuer_url, null))
}
