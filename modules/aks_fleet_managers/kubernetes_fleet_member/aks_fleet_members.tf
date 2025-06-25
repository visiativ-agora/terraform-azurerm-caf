resource "azurerm_kubernetes_fleet_member" "kfme" {
  name = var.settings.name
  kubernetes_cluster_id = "/subscriptions/4936a57f-886a-4874-9ff3-bbbf940bde45/resourcegroups/aks-re1/providers/microsoft.containerservice/managedclusters/akscluster-re1-001"
  kubernetes_fleet_id = var.kubernetes_fleet_id
}