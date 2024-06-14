resource "azurerm_site_recovery_replication_recovery_plan" "replication_plan" {
  depends_on = [time_sleep.delay_create]
  for_each   = try(var.settings.replication_plan, {})

  name                      = each.value.name
  recovery_vault_id         = azurerm_recovery_services_vault.asr.id
  source_recovery_fabric_id = try(each.value.source_recovery_fabric_id, null)
  target_recovery_fabric_id = try(each.value.target_recovery_fabric_id, null)
  # source_recovery_fabric_id = azurerm_site_recovery_fabric.recovery_fabric[each.value.source_recovery_fabric_key].id
  # target_recovery_fabric_id = azurerm_site_recovery_fabric.recovery_fabric[each.value.target_recovery_fabric_key].id


  dynamic "shutdown_recovery_group" {
    # for_each = try(each.value.shutdown_recovery_group, [])
    # for_each = try(each.value.shutdown_recovery_group, null) != null ? [each.value.shutdown_recovery_group] : []
    for_each = try(var.settings.replication_plan.shutdown_recovery_group, null) != null ? [var.settings.replication_plan.shutdown_recovery_group] : []
    content {
      dynamic "pre_action" {        
        # for_each = try(shutdown_recovery_group.value.pre_action, null) != null ? [shutdown_recovery_group.value.pre_action] : []
        # for_each = try(shutdown_recovery_group.value.pre_action, null) != null ? [1] : []
        for_each = try(var.var.settings.replication_plan.shutdown_recovery_group.pre_action, null) != null ? [var.settings.areplication_plan.shutdown_recovery_group.pre_action] : {}
        content {
          name                      = pre_action.value.name
          type                      = pre_action.value.type
          fail_over_directions      = pre_action.value.fail_over_directions
          fail_over_types           = pre_action.value.fail_over_types
          fabric_location           = try(pre_action.value.fabric_location, null)
          runbook_id                = try(pre_action.value.runbook_id, null)
          manual_action_instruction = try(pre_action.value.manual_action_instruction, null)
          script_path               = try(pre_action.value.script_path, null)
        }
      }

      dynamic "post_action" {
        # for_each = try(shutdown_recovery_group.value.post_action, [])
        # for_each = try(shutdown_recovery_group.value.post_action, null) != null ? [shutdown_recovery_group.value.post_action] : []
        for_each = try(shutdown_recovery_group.value.post_action, null) != null ? [1] : []
        content {
          name                      = post_action.value.name
          type                      = post_action.value.type
          fail_over_directions      = post_action.value.fail_over_directions
          fail_over_types           = post_action.value.fail_over_types
          fabric_location           = try(post_action.value.fabric_location, null)
          runbook_id                = try(post_action.value.runbook_id, null)
          manual_action_instruction = try(post_action.value.manual_action_instruction, null)
          script_path               = try(post_action.value.script_path, null)
        }
      }
    }
  }

  dynamic "failover_recovery_group" {
    for_each = try(each.value.failover_recovery_group, null) != null ? [each.value.failover_recovery_group] : []
    content {
      dynamic "pre_action" {
        # for_each = try(failover_recovery_group.value.pre_action, [])
        # for_each = try(failover_recovery_group.value.pre_action, null) != null ? [failover_recovery_group.value.pre_action] : []
        for_each = try(failover_recovery_group.value.pre_action, null) != null ? [1] : []
        content {
          name                      = pre_action.value.name
          type                      = pre_action.value.type
          fail_over_directions      = pre_action.value.fail_over_directions
          fail_over_types           = pre_action.value.fail_over_types
          fabric_location           = try(pre_action.value.fabric_location, null)
          runbook_id                = try(pre_action.value.runbook_id, null)
          manual_action_instruction = try(pre_action.value.manual_action_instruction, null)
          script_path               = try(pre_action.value.script_path, null)
        }
      }

      dynamic "post_action" {
        # for_each = try(failover_recovery_group.value.post_action, [])
        # for_each = try(failover_recovery_group.value.post_action, null) != null ? [failover_recovery_group.value.post_action] : []
        for_each = try(failover_recovery_group.value.post_action, null) != null ? [1] : []
        content {
          name                      = post_action.value.name
          type                      = post_action.value.type
          fail_over_directions      = post_action.value.fail_over_directions
          fail_over_types           = post_action.value.fail_over_types
          fabric_location           = try(post_action.value.fabric_location, null)
          runbook_id                = try(post_action.value.runbook_id, null)
          manual_action_instruction = try(post_action.value.manual_action_instruction, null)
          script_path               = try(post_action.value.script_path, null)
        }
      }
    }
  }

  dynamic "boot_recovery_group" {
    for_each = try(each.value.boot_recovery_group, null) != null ? [each.value.boot_recovery_group] : []
    content {      
      replicated_protected_items = try(each.value.boot_recovery_group.virtual_machines, [])
     
      dynamic "pre_action" {
        # for_each = try(boot_recovery_group.value.pre_action, [])
        # for_each = try(boot_recovery_group.value.pre_action, null) != null ? [boot_recovery_group.value.pre_action] : []
        for_each = try(boot_recovery_group.value.pre_action, null) != null ? [1] : []
        content {
          name                      = pre_action.value.name
          type                      = pre_action.value.type
          fail_over_directions      = pre_action.value.fail_over_directions
          fail_over_types           = pre_action.value.fail_over_types
          fabric_location           = try(pre_action.value.fabric_location, null)
          runbook_id                = try(pre_action.value.runbook_id, null)
          manual_action_instruction = try(pre_action.value.manual_action_instruction, null)
          script_path               = try(pre_action.value.script_path, null)
        }
      }

      dynamic "post_action" {
        # for_each = try(boot_recovery_group.value.post_action, [])
        # for_each = try(boot_recovery_group.value.post_action, null) != null ? [boot_recovery_group.value.post_action] : []
        for_each = try(boot_recovery_group.value.post_action, null) != null ? [1] : []
        content {
          name                      = post_action.value.name
          type                      = post_action.value.type
          fail_over_directions      = post_action.value.fail_over_directions
          fail_over_types           = post_action.value.fail_over_types
          fabric_location           = try(post_action.value.fabric_location, null)
          runbook_id                = try(post_action.value.runbook_id, null)
          manual_action_instruction = try(post_action.value.manual_action_instruction, null)
          script_path               = try(post_action.value.script_path, null)
        }
      }
    }
  }
}
