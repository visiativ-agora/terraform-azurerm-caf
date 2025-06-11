resource "azurerm_search_shared_private_link_service" "search_service_shared_private_link_service" {
  name               = var.settings.name
  search_service_id  = var.search_service_id
  subresource_name   = var.settings.subresource_name
  target_resource_id = var.target_resource_id
  request_message    = try(var.settings.request_message, null)
}


# resource "time_sleep" "wait_for_private_endpoint" {
#   create_duration = "2m"
#   depends_on      = [azurerm_search_shared_private_link_service.search_service_shared_private_link_service]

#   triggers = {
#     timestamp = timestamp()
#   }
# }

# # Map des types de ressources et leurs API versions
# locals {
#   target_resource_apis = {
#     "Microsoft.Storage/storageAccounts"     = "2023-01-01"
#     "Microsoft.Sql/servers"                 = "2023-05-01-preview"
#   }
# }

# # Récupération des connexions Private Endpoint
# data "azapi_resource" "target_resource" {
#   type                   = "${var.target_resource_type}@${local.target_resource_apis[var.target_resource_type]}"
#   resource_id            = var.target_resource_id
#   response_export_values = ["properties.privateEndpointConnections"]
  
#   depends_on = [time_sleep.wait_for_private_endpoint]
# }

# # Extraction de la connexion en attente
# locals {
#   connections = try(jsondecode(data.azapi_resource.target_resource.output).properties.privateEndpointConnections, [])
  
#   pending_connection = try(
#     [for conn in local.connections : conn if conn.properties.privateLinkServiceConnectionState.status == "Pending"][0],
#     null
#   )
# }

# # Auto-approbation via azapi
# resource "azapi_update_resource" "approve_connection" {
#   count = local.pending_connection != null ? 1 : 0

#   type        = "${var.target_resource_type}/privateEndpointConnections@${local.target_resource_apis[var.target_resource_type]}"
#   resource_id = local.pending_connection.id

#   body = jsonencode({
#     properties = {
#       privateLinkServiceConnectionState = {
#         status      = "Approved"
#         description = "Auto-approved by Terraform"
#       }
#     }
#   })

#   lifecycle {
#     ignore_changes = [body] # Empêche la reconfirmation permanente
#   }
# }