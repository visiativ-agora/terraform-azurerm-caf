resource "azurerm_search_shared_private_link_service" "search_service_shared_private_link_service" {
  name               = var.settings.name
  search_service_id  = var.search_service_id
  subresource_name   = var.settings.subresource_name
  target_resource_id = var.target_resource_id
  request_message    = try(var.settings.request_message, null)
}
