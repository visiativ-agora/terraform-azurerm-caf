global_settings = {
  default_region = "region1"
  regions = {
    region1 = "eastus"
  }
  inherit_tags = true
}

resource_groups = {
  rg1 = {
    name     = "RG1"
    location = "region1"
  }
}

search_services = {
  ss1 = {
    name               = "ss003"
    resource_group_key = "rg1"
    region             = "region1"
    sku                = "standard"
    identity = {
      type = "SystemAssigned"
    }
    local_authentication_enabled = false
    # public_network_access_enabled = true
    # allowed_ips                   = ["13.478.57.73"]

    private_endpoints = {
      pe1 = {
        name               = "search"
        resource_group_key = "rg1"

        # lz_key     = ""
        vnet_key   = "vnet1"
        subnet_key = "pep"

        private_service_connection = {
          name                 = "search"
          is_manual_connection = false
          subresource_names    = ["searchService"]
        }
        private_dns = {
          lz_key = "dns"
          keys   = ["search"]
        }
      }
    }

    shared_private_access = {
      spa1 = {
        name = "spa"
        target_resource = {
          type   = "cosmosdbaccount" # Possible values : "storage", "cosmosdb"
          lz_key = ""
          key    = "cosmosdb_account_re1"
        }
        subresource_name = "Sql"
        auto_approve     = true
        request_message  = "Approved by Terraform"
      }
    }
  }
}


vnets = {
  vnet1 = {
    resource_group_key = "rg1"
    vnet = {
      name          = "search"
      address_space = ["100.64.100.0/22"]
    }
    specialsubnets = {}
    subnets = {
      pep = {
        name                                           = "pep"
        cidr                                           = ["100.64.103.0/27"]
        enforce_private_link_endpoint_network_policies = "true"
      }
    }
  }
}

private_dns = {
  dns = {
    name               = "privatelink.search.windows.net"
    resource_group_key = "rg1"
    vnet_links = {
      vnlnk1 = {
        name     = "search"
        vnet_key = "vnet1"
      }
    }
  }
}


managed_identities = {
  demo1 = {
    name               = "demo1"
    resource_group_key = "rg1"
  }
}

cosmos_dbs = {
  cosmosdb_account_re1 = {
    name                      = "cosmosdb"
    resource_group_key        = "rg1"
    offer_type                = "Standard"
    kind                      = "GlobalDocumentDB"
    enable_automatic_failover = "true"

    #This parameter needs for more correct work with Cosmos custom roles
    access_key_metadata_writes_enabled = false

    consistency_policy = {
      consistency_level       = "BoundedStaleness"
      max_interval_in_seconds = "300"
      max_staleness_prefix    = "100000"
    }

    geo_locations = {
      primary_geo_location = {
        prefix            = "customid-101"
        region            = "region1"
        zone_redundant    = false
        failover_priority = 0
      }
    }

    local_authentication_disabled = true
  }
}
