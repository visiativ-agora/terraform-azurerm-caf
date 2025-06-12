resource "azurerm_search_shared_private_link_service" "search_service_shared_private_link_service" {
  name               = var.settings.name
  search_service_id  = var.search_service_id
  subresource_name   = var.settings.subresource_name
  target_resource_id = var.target_resource_id
  request_message    = try(var.settings.request_message, null)
}


resource "time_sleep" "wait_for_private_endpoint" {
  create_duration = "2m"
  depends_on      = [azurerm_search_shared_private_link_service.search_service_shared_private_link_service]

  triggers = {
    timestamp = timestamp()
  }
}

# Récupération des connexions Private Endpoint
data "azapi_resource" "target_resource" {
  type                   = "${var.target_resource_type}@${var.target_resource_api_version}"
  resource_id            = var.target_resource_id
  response_export_values = ["properties.privateEndpointConnections"]
  
  depends_on = [time_sleep.wait_for_private_endpoint]
}

# Extraction de la connexion en attente
locals {
  connections = try(jsondecode(data.azapi_resource.target_resource.output).properties.privateEndpointConnections, [])
  
  pending_connection = try(
    [for conn in local.connections : conn if conn.properties.privateLinkServiceConnectionState.status == "Pending"][0],
    null
  )
}

resource "terraform_data" "pe_name" {
  input = var.settings.name
}

# Auto-approbation via azapi
resource "azapi_update_resource" "approve_connection" {
  count = var.settings.auto_approve ? 1 : 0

  type        = "${var.target_resource_type}/privateEndpointConnections@${var.target_resource_api_version}"
    
  resource_id = try(local.pending_connection.id, null)
  # resource_id = "/subscriptions/05fb9a2a-6ca0-467a-aacd-c1f92acf123a/resourceGroups/RSG30111902BOT001/providers/Microsoft.DocumentDB/databaseAccounts/dat30111902cdb001/privateEndpointConnections/NET30111902SPA007-SEA"

  body = jsonencode({
    properties = {
      privateLinkServiceConnectionState = {
        status      = "Approved"
        description = "Approved by Terraform"
      }
    }
  })

  lifecycle {
    ignore_changes = [body] # Empêche la reconfirmation permanente
    replace_triggered_by = [terraform_data.pe_name]
  }

  depends_on = [
    data.azapi_resource.target_resource
  ]  
}


# /subscriptions/05fb9a2a-6ca0-467a-aacd-c1f92acf123a/resourceGroups/RSG30111902BOT001/providers/Microsoft.DocumentDB/databaseAccounts/dat30111902cdb001/privateEndpointConnections/NET30111902SPA007-SEA
# /subscriptions/4b6e02e4-1c2e-45fe-aa8d-fad6a8531fe4/resourceGroups/azspppe/providers/Microsoft.Network/privateEndpoints/NET30111902SPA007-SEA