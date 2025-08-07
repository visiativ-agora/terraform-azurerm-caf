output "id" {
  value = azurerm_kubernetes_fleet_manager.kfm.id
}

output "aks_clusters" {
  value = var.aks_clusters
}