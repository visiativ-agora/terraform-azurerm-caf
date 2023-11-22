resource_groups = {
  dmz-rt-dev-network = {
    # Existing resource group name
    name  = "fibc-rg-mi-networking-re1"
    reuse = true
  }
}

storage_accounts = {
  sa1 = {
    name                     = "functionsapptestsa"
    resource_group_key       = "dmz-rt-dev-network"
    region                   = "region1"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
}

app_service_plans = {
  asp1 = {
    name               = "azure-functions-test-service-plan"
    resource_group_key = "dmz-rt-dev-network"
    region             = "region1"
    kind               = "functionapp"
    reserved           = true

    sku = {
      tier = "Dynamic"
      size = "Y1"
    }
  }
}

function_apps = {
  faaps1 = {
    name                 = "test-azure-functions"
    resource_group_key   = "dmz-rt-dev-network"
    region               = "region1"
    app_service_plan_key = "asp1"
    storage_account_key  = "sa1"
    settings = {
      os_type = "linux"
      version = "~3"
    }
  }
}