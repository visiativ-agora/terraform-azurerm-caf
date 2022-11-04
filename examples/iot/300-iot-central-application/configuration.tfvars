global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
}

resource_groups = {
  ioth_region1 = {
    name   = "iothub-rg1"
    region = "region1"
  }
}

iot_central_application = {
  app1 = {
    name               = "example-iotcentral-app"
    resource_group_key = "ioth_region1"
    sub_domain         = "example-iotcentral-app-subdomain-abc"
    display_name       = "example-iotcentral-app-display-name"
    sku                = "ST1"
    # template            = "iotc-default@1.0.0"
    tags = {
      Foo = "Bar"
    }
  }
}
 