resource "azurerm_kubernetes_fleet_member" "kfme" {
  for_each = {
    for fm in local.fleet_members : "${fm.name}-${fm.lz_key}-${fm.key}" => fm
  }

  name                   = each.value.name
  kubernetes_cluster_id  = var.kubernetes_cluster_id[each.value.lz_key][each.value.key].id
  kubernetes_fleet_id    = var.kubernetes_fleet_id
}
