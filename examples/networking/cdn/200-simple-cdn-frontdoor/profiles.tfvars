cdn_profile = {
  example_profile = {
    name = "exampleprofile"
    resource_group = {
      key = "cdn_profile_example_key"
    }
    region = "region1"
    sku    = "Standard_Microsoft"
  }
}

cdn_frontdoor_profile = {
  example_cdn_frontdoor_profile = {
    name   = "example-profile"    
    resource_group = {
      key = "cdn_frontdoor_region1"
    }
    sku_name = "Standard_AzureFrontDoor"
  }
}