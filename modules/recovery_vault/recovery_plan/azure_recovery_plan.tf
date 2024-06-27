resource "azurerm_site_recovery_replication_recovery_plan" "replication_plan" {

  name                      = var.settings.name
  recovery_vault_id         = var.recovery_vault_id[var.settings.recovery_vault_key]
  source_recovery_fabric_id = var.recovery_fabrics[var.settings.source_recovery_fabric_key].id
  target_recovery_fabric_id = var.recovery_fabrics[var.settings.target_recovery_fabric_key].id


  dynamic "shutdown_recovery_group" {
    for_each = try(var.settings.shutdown_recovery_group, [])
    # for_each = try(var.settings.shutdown_recovery_group, null) != null ? [var.settings.shutdown_recovery_group] : []
    # for_each = try(var.settings.replication_plan.shutdown_recovery_group, null) != null ? [var.settings.replication_plan.shutdown_recovery_group] : []
    content {
      dynamic "pre_action" {
        # for_each = try(shutdown_recovery_group.value.pre_action, null) != null ? [shutdown_recovery_group.value.pre_action] : []
        # for_each = try(shutdown_recovery_group.value.pre_action, null) != null ? [1] : []
        for_each = try(var.settings.replication_plan.shutdown_recovery_group.pre_action, null) != null ? [var.settings.areplication_plan.shutdown_recovery_group.pre_action] : []
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
        for_each = try(shutdown_recovery_group.value.post_action, [])
        # for_each = try(shutdown_recovery_group.value.post_action, null) != null ? [shutdown_recovery_group.value.post_action] : []
        # for_each = try(shutdown_recovery_group.value.post_action, null) != null ? [1] : []
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
    for_each = try(var.settings.failover_recovery_group, null) != null ? [var.settings.failover_recovery_group] : []
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
    for_each = try(var.settings.boot_recovery_group, null) != null ? [var.settings.boot_recovery_group] : []
    content {
      # replicated_protected_items = azurerm_site_recovery_replicated_vm.replication[var.settings.replicated_objects_id]
      replicated_protected_items = coalesce(
        try(var.virtual_machines_replication[var.settings.replication_plan.boot_recovery_group.virtual_machines_key], null),
        try(var.settings.replication_plan.boot_recovery_group.virtual_machines, null)
      )
      # replicated_protected_items = flatten([for v in var.settings.virtual_machines : [
      #   var.virtual_machines_replication[try(v.lz_key, var.client_config.landingzone_key)][v.key]
      # ]])

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
