resource "azurerm_kubernetes_fleet_member" "kfme" {
  for_each = {
    for m in local.fleet_members : "${m.fleet_key}-${m.group_key}-${m.name}" => m
  }

  name                  = each.value.name
  kubernetes_cluster_id = var.kubernetes_cluster_id[each.value.lz_key][each.value.key].id
  kubernetes_fleet_id   = module.kubernetes_fleet_managers[each.value.fleet_key].id
}
