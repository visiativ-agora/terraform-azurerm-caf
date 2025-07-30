output "id" {
  value = { for k, v in azurerm_kubernetes_fleet_member.kfme : k => v.id }
}