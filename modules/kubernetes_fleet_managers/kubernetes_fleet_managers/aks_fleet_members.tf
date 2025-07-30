resource "azurerm_kubernetes_fleet_member" "kfme" {
  for_each = local.fleet_members

  name                  = each.value.name
  kubernetes_cluster_id = var.kubernetes_cluster_id[each.value.lz_key][each.value.key].id
  kubernetes_fleet_id   = azurerm_kubernetes_fleet_manager.kfm.id
}
