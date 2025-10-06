# Approximative time to
#  - deploy: 25 mins to 30 mins
#  - destroy: 5 mins
#
# rover -lz /tf/caf/solutions/ -var-file /tf/caf/solutions/examples/redis_cache/redis-std.tfvars -a apply

global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
}

resource_groups = {
  redis_region1 = {
    name   = "redis-std-rg"
    region = "region1"
  }
}

managed_identities = {
  mi1 = {
    name               = "redis_mi1"
    resource_group_key = "redis_region1"
  }
}

azurerm_redis_caches = {
  r1 = {
    resource_group_key = "redis_region1"
    redis = {
      name          = "redis-std-1"
      capacity      = 2
      family        = "C"
      sku_name      = "Standard"
      redis_version = 6

      redis_configuration = {
        rdb_backup_enabled                      = false
        active_directory_authentication_enabled = true
      }

      redis_role_assignment = {
        "Data Contributor" = {
          managed_identities = {
            # lz_key = ""
            keys = ["mi1"]
          }
        }
      }
    }
    tags = {
      test = "AK1"
    }
  }
  r2 = {
    resource_group_key = "redis_region1"
    redis = {
      name          = "redis-std-2"
      capacity      = 1
      family        = "C"
      sku_name      = "Basic"
      redis_version = 6
    }
    tags = {
      test = "AK2"
    }
  }
}

