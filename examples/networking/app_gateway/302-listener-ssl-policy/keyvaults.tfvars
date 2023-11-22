keyvaults = {
  certificates = {
    name               = "demo_certs"
    resource_group_key = "agw_region1"
    sku_name           = "standard"

    enabled_for_deployment = true

    creation_policies = {
      logged_in_user = {
        certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Purge", "Recover"]
        secret_permissions      = ["Set", "Get", "List", "Delete", "Purge", "Recover"]
      }
    }
  }
}

keyvault_access_policies = {
  certificates = {
    agw1_keyvault_demo_certs = {
      managed_identity_key    = "agw1_keyvault_demo_certs"
      certificate_permissions = ["Get"]
      secret_permissions      = ["Get"]
    }
  }
}