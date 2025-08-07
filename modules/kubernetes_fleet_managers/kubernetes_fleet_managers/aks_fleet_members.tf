resource "azurerm_kubernetes_fleet_member" "kfme" {
  for_each = local.fleet_members

  name = each.value.name
  # kubernetes_cluster_id = var.kubernetes_cluster_id[each.value.lz_key][each.value.key].id
  # kubernetes_cluster_id = try(var.remote_objects.aks_clusters[each.value.lz_key][each.value.key].id, "toto")
  kubernetes_cluster_id           = try(var.combined_resources.aks_clusters[each.value.lz_key][each.value.key].id, "toto")

  # kubernetes_cluster_id = try(var.aks_clusters[try(each.value.lz_key, var.client_config.landingzone_key)][var.value.key].id, null)
  kubernetes_fleet_id   = azurerm_kubernetes_fleet_manager.kfm.id
}


# resource "null_resource" "example11" {

#   provisioner "local-exec" {

#     command = "echo '${jsonencode(var.remote_objects.aks_clusters["aks"])}'"

#   }

# }

# resource "null_resource" "example13" {

#   provisioner "local-exec" {

#     command = "echo '${jsonencode(var.remote_objects.aks_clusters)}'"

#   }

# }
