output "id" {
  value = azurerm_mssql_database.mssqldb.id
}

output "name" {
  value = azurerm_mssql_database.mssqldb.name
}

output "server_id" {
  value = azurerm_mssql_database.mssqldb.server_id
}

output "server_name" {
  value = var.server_name
}

output "server_fqdn" {
  value = local.server_name
}

# output "job_agent_id" {
#   value       = azapi_resource.mssql_job_agents[0].id
# }

# output "job_agent_id" {
#   description = "ID of the MSSQL job agentt"
#   value = {
#     for k, v in azurerm_mssql_job_agent.mssqljobagent : k => v.id
#   }
# }

# output "job_targetgroups_ids" {
#   value = {
#     for k, v in azapi_resource.sqldatabasejobstargetgroups : k => v.id
#   }
# }

# output "sql_user_creation_logs" {
#   value = {
#     for user in var.settings.sql_users :
#     user => {
#       stdout = file("${azurerm_mssql_database.mssqldb.name}_stdout.log")
#       stderr = file("${azurerm_mssql_database.mssqldb.name}_stderr.log")
#     }
#   }
# }