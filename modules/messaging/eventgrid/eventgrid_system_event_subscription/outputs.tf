# output "id" {
#   value       = azurerm_eventgrid_system_topic_event_subscription.eges.id
#   description = "The ID of the EventGrid System Event Subscription."
# }
output "dbg_functions_core_keys" {
  value = keys(var.remote_objects.functions["core_dev_fileshare"])
}
output "dbg_functions_core_f1" {
  value = try(var.remote_objects.functions["core_dev_fileshare"]["f1"], null)
}