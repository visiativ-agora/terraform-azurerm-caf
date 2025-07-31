resource "azurerm_kubernetes_fleet_member" "kfme" {
  for_each = local.fleet_members

  name = each.value.name
  # kubernetes_cluster_id = var.kubernetes_cluster_id[each.value.lz_key][each.value.key].id
  kubernetes_cluster_id = var.remote_objects.aks_clusters[each.value.lz_key][each.key].id
  kubernetes_fleet_id   = azurerm_kubernetes_fleet_manager.kfm.id
}


resource "null_resource" "example1" {

  provisioner "local-exec" {

    command = "echo '${jsonencode(var.kubernetes_cluster_id["aks"])}'"

  }

}


resource "null_resource" "example2" {

  provisioner "local-exec" {

    command = "echo '${jsonencode(local.fleet_members)}'"

  }

}
