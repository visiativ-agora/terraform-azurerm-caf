global_settings = {
  default_region = "region1"
  regions = {
    region1 = "francecentrale"
  }
}

resource_groups = {
  cdn_frontdoor_region1 = {
    name   = "example-cdn-frontdoor"
    region = "region1"
  }
}