# resource "azurerm_kubernetes_fleet_member" "kfme" {
#   name = var.settings.name
#   kubernetes_cluster_id = "/subscriptions/4936a57f-886a-4874-9ff3-bbbf940bde45/resourcegroups/aks-re1/providers/microsoft.containerservice/managedclusters/akscluster-re1-001"
#   kubernetes_fleet_id = var.kubernetes_fleet_id
# }

resource "azurerm_kubernetes_fleet_member" "kfme" {
  for_each = {
    for member in var.members :
    "${member.lz_key}.${member.keys}" => {
      lz_key = member.lz_key
      key    = member.keys
    }
  }

  name                = each.value.key
  kubernetes_fleet_id = data.azurerm_kubernetes_fleet_manager.kfm.id
  kubernetes_cluster_id = module.landingzone[each.value.lz_key].resources.aks[each.value.key].id
}