# resource "azurerm_mssql_job_agent" "mssqljobagent" {
#   for_each    = try(var.settings.jobs, {})
#   name        = each.value.name
#   location    = var.location
#   database_id = azurerm_mssql_database.mssqldb.id
#   tags        = local.tags
# }

# resource "azapi_resource" "job" {
#   for_each = try(var.settings.jobs, {})

#   type                      = "Microsoft.Sql/servers/jobAgents/jobs@2024-05-01-preview"
#   schema_validation_enabled = false
#   name                      = try(each.value.name, null)
#   parent_id                 = azurerm_mssql_job_agent.mssqljobagent[each.key].id
#   body = jsonencode({
#     properties = {
#       description = try(each.value.description, null)
#       schedule = {
#         enabled   = try(each.value.schedule.enabled, null)
#         startTime = try(each.value.schedule.startTime, null)
#         endTime   = try(each.value.schedule.endTime, null)
#         interval  = try(each.value.schedule.interval, null)
#         type      = try(each.value.schedule.type, null)
#       }
#     }
#   })
# }

# resource "azapi_resource" "sqldatabasejobtargetgroup" {
#   for_each = {
#     for item in flatten([
#       for job_key, job_value in try(var.settings.jobs, {}) : [
#         for tg_key, tg_value in try(job_value.targetgroups, {}) : {
#           tg_key   = tg_key
#           job_key  = job_key
#           tg_value = tg_value
#         }
#       ]
#     ]) : item.tg_key => item
#   }

#   type                      = "Microsoft.Sql/servers/jobAgents/targetGroups@2024-05-01-preview"
#   name                      = each.value.tg_value.name
#   parent_id                 = azurerm_mssql_job_agent.mssqljobagent[each.value.job_key].id
#   schema_validation_enabled = false

#   body = jsonencode({
#     properties = {
#       members = [
#         {
#           databaseName   = azurerm_mssql_database.mssqldb.name
#           serverName     = var.mssql_servers[try(var.settings.lz_key, var.client_config.landingzone_key)][var.settings.mssql_server_key].name
#           membershipType = each.value.tg_value.members.membershipType
#           type           = "SqlDatabase"
#         }
#       ]
#     }
#   })
# }

# resource "azapi_resource" "jobstep" {
#   for_each = {
#     for idx, item in flatten([
#       for job_key, job in try(var.settings.jobs, {}) : [
#         for step_key, step in job.steps : {
#           job_key  = job_key
#           step_key = step_key
#           step     = step
#         }
#       ]
#     ]) : "${item.job_key}-${item.step_key}" => item
#   }

#   type                      = "Microsoft.Sql/servers/jobAgents/jobs/steps@2024-05-01-preview"
#   schema_validation_enabled = false
#   name                      = each.value.step.name
#   parent_id                 = azapi_resource.job[each.value.job_key].id
#   body = jsonencode({
#     properties = {
#       action = {
#         source = each.value.step.action.source
#         type   = each.value.step.action.type
#         value  = each.value.step.action.value
#       }
#       credential = try(each.value.step.credential, null)
#       executionOptions = lookup(each.value.step, "executionOptions", null) != null ? {
#         initialRetryIntervalSeconds    = try(each.value.step.executionOptions.initialRetryIntervalSeconds, null)
#         maximumRetryIntervalSeconds    = try(each.value.step.executionOptions.maximumRetryIntervalSeconds, null)
#         retryAttempts                  = try(each.value.step.executionOptions.retryAttempts, null)
#         retryIntervalBackoffMultiplier = try(each.value.step.executionOptions.retryIntervalBackoffMultiplier, null)
#         timeoutSeconds                 = try(each.value.step.executionOptions.timeoutSeconds, null)
#       } : null
#       stepId      = each.value.step.stepId
#       targetGroup = azapi_resource.sqldatabasejobtargetgroup[keys(var.settings.job[each.value.job_key].targetgroups)[0]].id
#     }
#   })
# }
