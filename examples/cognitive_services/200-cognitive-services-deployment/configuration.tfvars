global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westus"
  }
  random_length = 5
}

resource_groups = {
  test-rg = {
    name = "rg-alz-caf-test-1"
  }
}

cognitive_services_account = {
  test_account-1 = {
    resource_group = {
      # accepts either id or key to get resource group id
      # id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourceGroup1"
      # lz_key = "examples"
      key = "test-rg"
    }
    name     = "cs-alz-caf-test-1"
    kind     = "ComputerVision"
    sku_name = "F0"
    tags = {
      env = "test"
    }
    deployment = {
        test_deployment-1 = {
          name          = "cs-dep-caf-test-1"
          model_format  = "OpenAI"
          model_name    = "cs-dep-caf-test-1"
          model_version = "2"
          scale_type    = "Standard"
          scale_capacity  = 1 
        }
      }
  }
}

