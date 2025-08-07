resource "azurerm_kubernetes_fleet_member" "kfme" {
  for_each = local.fleet_members

  name                  = each.value.name
  kubernetes_cluster_id = try(var.aks_clusters[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.key].id, null)
  kubernetes_fleet_id   = azurerm_kubernetes_fleet_manager.kfm.id
}
