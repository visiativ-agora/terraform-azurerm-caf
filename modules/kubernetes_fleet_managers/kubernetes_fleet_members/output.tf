output "ids" {
  value = [for fm in azurerm_kubernetes_fleet_member.kfme : fm.value.id]
}