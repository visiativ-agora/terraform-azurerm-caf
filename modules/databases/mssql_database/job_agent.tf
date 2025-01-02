resource "azurerm_mssql_job_agent" "mssqljobagent" {
  count       = var.settings.job.name != "" ? 1 : 0
  name        = var.settings.job.name
  location    = var.location
  database_id = azurerm_mssql_database.mssqldb.id
  tags        = local.tags
}