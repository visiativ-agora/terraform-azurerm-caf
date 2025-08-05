# Per options https://www.terraform.io/docs/providers/azurerm/r/app_service.html

resource "azurerm_linux_function_app_slot" "slots" {
  for_each = var.slots

  name                               = each.value.name
  function_app_id                    = azurerm_linux_function_app.linux_function_app.id
  client_certificate_enabled         = lookup(var.settings, "client_certificate_enabled", null)
  client_certificate_mode            = lookup(var.settings, "client_certificate_mode", null)
  client_certificate_exclusion_paths = lookup(var.settings, "client_certificate_exclusion_paths", null)
  enabled                            = lookup(var.settings, "enabled", null)
  https_only                         = lookup(var.settings, "https_only", null)
  public_network_access_enabled      = lookup(var.settings, "public_network_access_enabled", null)
  key_vault_reference_identity_id    = can(var.settings.key_vault_reference_identity.key) ? var.combined_objects.managed_identities[try(var.settings.identity.lz_key, var.client_config.landingzone_key)][var.settings.key_vault_reference_identity.key].id : try(var.settings.key_vault_reference_identity.id, null)
  tags                               = local.tags

  dynamic "identity" {
    for_each = try(var.identity, null) != null ? [1] : []

    content {
      type         = try(var.identity.type, null)
      identity_ids = lower(var.identity.type) == "userassigned" ? local.managed_identities : null
    }
  }

  dynamic "site_config" {
    for_each = lookup(var.settings, "site_config", {}) != {} ? [1] : []

    content {
      # numberOfWorkers           = lookup(each.value.site_config, "numberOfWorkers", 1)  # defined in ARM template below
      always_on             = lookup(var.settings.site_config, "always_on", null)
      api_management_api_id = lookup(var.settings.site_config, "api_management_api_id", null)
      api_definition_url    = lookup(var.settings.site_config, "api_definition_url", null)
      app_command_line      = lookup(var.settings.site_config, "app_command_line", null)

      dynamic "application_stack" {
        for_each = lookup(var.settings.site_config, "application_stack", {}) != {} ? [1] : []
        content {
          docker_image_name        = lookup(var.settings.site_config.application_stack, "docker_image_name", null)
          docker_registry_url      = lookup(var.settings.site_config.application_stack, "docker_registry_url", null)
          docker_registry_username = lookup(var.settings.site_config.application_stack, "docker_registry_username", null)
          docker_registry_password = lookup(var.settings.site_config.application_stack, "docker_registry_password", null)
          dotnet_version           = lookup(var.settings.site_config.application_stack, "dotnet_version", null)
          go_version               = lookup(var.settings.site_config.application_stack, "go_version", null)
          java_version             = lookup(var.settings.site_config.application_stack, "java_version", null)
          java_server              = lookup(var.settings.site_config.application_stack, "java_server", null)
          java_server_version      = lookup(var.settings.site_config.application_stack, "java_server_version", null)
          node_version             = lookup(var.settings.site_config.application_stack, "node_version", null)
          php_version              = lookup(var.settings.site_config.application_stack, "php_version", null)
          python_version           = lookup(var.settings.site_config.application_stack, "python_version", null)
          ruby_version             = lookup(var.settings.site_config.application_stack, "ruby_version", null)
        }
      }

      auto_heal_enabled = lookup(var.settings.site_config, "auto_heal_enabled", null)

      # dynamic "auto_heal_setting" {
      #   for_each = lookup(var.settings.site_config, "auto_heal_setting", {}) != {} ? [1] : []
      #   content {
      #     action  = lookup(var.settings.site_config.auto_heal_setting, "action", null)
      #     trigger = lookup(var.settings.site_config.auto_heal_setting, "trigger", null)
      #   }
      # }

      dynamic "auto_heal_setting" {
        for_each = lookup(var.settings.site_config, "auto_heal_setting", {}) != {} ? [1] : []

        content {
          dynamic "action" {
            for_each = lookup(var.settings.site_config.auto_heal_setting, "action", {}) != {} ? [lookup(var.settings.site_config.auto_heal_setting, "action", {})] : []
            content {
              action_type                    = lookup(action.value, "action_type", null)
              minimum_process_execution_time = lookup(action.value, "minimum_process_execution_time ", null)
            }
          }
          dynamic "trigger" {
            for_each = lookup(var.settings.site_config.auto_heal_setting, "trigger", {}) != {} ? [lookup(var.settings.site_config.auto_heal_setting, "trigger", {})] : []
            content {
              dynamic "requests" {
                for_each = lookup(trigger.value, "requests", {}) != {} ? [lookup(trigger.value, "requests", {})] : []
                content {
                  count    = lookup(requests.value, "count", null)
                  interval = lookup(requests.value, "interval", null)
                }
              }
              dynamic "slow_request" {
                for_each = lookup(trigger.value, "slow_request", {}) != {} ? [lookup(trigger.value, "slow_request", {})] : []
                content {
                  count      = lookup(slow_request.value, "count", null)
                  interval   = lookup(slow_request.value, "interval", null)
                  time_taken = lookup(slow_request.value, "time_taken", null)
                  path       = lookup(slow_request.value, "path", null)
                }
              }
              dynamic "status_code" {
                for_each = lookup(trigger.value, "status_code", {}) != {} ? [lookup(trigger.value, "status_code", {})] : []
                content {
                  count             = lookup(status_code.value, "count", null)
                  interval          = lookup(status_code.value, "interval", null)
                  status_code_range = lookup(status_code.value, "status_code_range", null)
                  path              = lookup(status_code.value, "path", null)
                  sub_status        = lookup(status_code.value, "sub_status", null)
                  win32_status_code = lookup(status_code.value, "win32_status_code", null)

                }
              }
              dynamic "slow_request_with_path" {
                for_each = lookup(trigger.value, "slow_request_with_path", {}) != {} ? [lookup(trigger.value, "slow_request_with_path", {})] : []
                content {
                  count      = lookup(slow_request_with_path.value, "count", null)
                  interval   = lookup(slow_request_with_path.value, "interval", null)
                  time_taken = lookup(slow_request_with_path.value, "time_taken", null)
                  path       = lookup(slow_request_with_path.value, "path", null)
                }
              }
            }
          }
        }
      }


      auto_swap_slot_name                           = lookup(var.settings.site_config, "auto_swap_slot_name", null)
      container_registry_managed_identity_client_id = lookup(var.settings.site_config, "container_registry_managed_identity_client_id", null)
      container_registry_use_managed_identity       = lookup(var.settings.site_config, "container_registry_use_managed_identity", null)


      dynamic "cors" {
        for_each = lookup(var.settings.site_config, "cors", {}) != {} ? [1] : []

        content {
          allowed_origins     = lookup(var.settings.site_config.cors, "allowed_origins", null)
          support_credentials = lookup(var.settings.site_config.cors, "support_credentials", null)
        }
      }

      default_documents                 = lookup(var.settings.site_config, "default_documents", null)
      ftps_state                        = lookup(var.settings.site_config, "ftps_state", null)
      health_check_path                 = lookup(var.settings.site_config, "health_check_path", null)
      health_check_eviction_time_in_min = lookup(var.settings.site_config, "health_check_eviction_time_in_min", null)
      http2_enabled                     = lookup(var.settings.site_config, "http2_enabled", null)

      dynamic "ip_restriction" {
        for_each = try(var.settings.site_config.ip_restriction, {})

        content {
          action                    = lookup(ip_restriction.value, "action", null)
          ip_address                = lookup(ip_restriction.value, "ip_address", null)
          service_tag               = lookup(ip_restriction.value, "service_tag", null)
          virtual_network_subnet_id = can(ip_restriction.value.virtual_network_subnet_id) || can(ip_restriction.value.virtual_network_subnet.id) || can(ip_restriction.value.virtual_network_subnet.subnet_key) == false ? try(ip_restriction.value.virtual_network_subnet_id, ip_restriction.value.virtual_network_subnet.id, null) : var.combined_objects.networking[try(ip_restriction.value.virtual_network_subnet.lz_key, var.client_config.landingzone_key)][ip_restriction.value.virtual_network_subnet.vnet_key].subnets[ip_restriction.value.virtual_network_subnet.subnet_key].id
          name                      = lookup(ip_restriction.value, "name", null)
          priority                  = lookup(ip_restriction.value, "priority", null)


          dynamic "headers" {
            for_each = try(ip_restriction.headers, {})

            content {
              x_azure_fdid      = lookup(headers.value, "x_azure_fdid", null)
              x_fd_health_probe = lookup(headers.value, "x_fd_health_probe", null)
              x_forwarded_for   = lookup(headers.value, "x_forwarded_for", null)
              x_forwarded_host  = lookup(headers.value, "x_forwarded_host", null)
            }
          }
        }
      }
      scm_ip_restriction_default_action = lookup(var.settings.site_config, "scm_ip_restriction_default_action", null)
      dynamic "scm_ip_restriction" {
        for_each = try(var.settings.site_config.scm_ip_restriction, {})

        content {
          ip_address                = lookup(scm_ip_restriction.value, "ip_address", null)
          service_tag               = lookup(scm_ip_restriction.value, "service_tag", null)
          virtual_network_subnet_id = can(scm_ip_restriction.value.virtual_network_subnet_id) ? scm_ip_restriction.value.virtual_network_subnet_id : can(scm_ip_restriction.value.virtual_network_subnet.id) ? scm_ip_restriction.value.virtual_network_subnet.id : can(scm_ip_restriction.value.virtual_network_subnet.subnet_key) ? var.combined_objects.networking[try(scm_ip_restriction.value.virtual_network_subnet.lz_key, var.client_config.landingzone_key)][scm_ip_restriction.value.virtual_network_subnet.vnet_key].subnets[scm_ip_restriction.value.virtual_network_subnet.subnet_key].id : null
          name                      = lookup(scm_ip_restriction.value, "name", null)
          priority                  = lookup(scm_ip_restriction.value, "priority", null)
          action                    = lookup(scm_ip_restriction.value, "action", null)
          dynamic "headers" {
            for_each = try(scm_ip_restriction.headers, {})

            content {
              x_azure_fdid      = lookup(headers.value, "x_azure_fdid", null)
              x_fd_health_probe = lookup(headers.value, "x_fd_health_probe", null)
              x_forwarded_for   = lookup(headers.value, "x_forwarded_for", null)
              x_forwarded_host  = lookup(headers.value, "x_forwarded_host", null)
            }
          }
        }
      }
      ip_restriction_default_action = lookup(var.settings.site_config, "ip_restriction_default_action", null)
      scm_minimum_tls_version       = lookup(var.settings.site_config, "scm_minimum_tls_version", null)
      scm_use_main_ip_restriction   = lookup(var.settings.site_config, "scm_use_main_ip_restriction", null)
      use_32_bit_worker             = lookup(var.settings.site_config, "use_32_bit_worker", null)
      vnet_route_all_enabled        = lookup(var.settings.site_config, "vnet_route_all_enabled", null)
      websockets_enabled            = lookup(var.settings.site_config, "websockets_enabled", null)
      worker_count                  = lookup(var.settings.site_config, "worker_count", null)
      load_balancing_mode           = lookup(var.settings.site_config, "load_balancing_mode", null)
      local_mysql_enabled           = lookup(var.settings.site_config, "local_mysql_enabled", null)
      managed_pipeline_mode         = lookup(var.settings.site_config, "managed_pipeline_mode", null)
      minimum_tls_version           = lookup(var.settings.site_config, "minimum_tls_version", null)
      remote_debugging_enabled      = lookup(var.settings.site_config, "remote_debugging_enabled", null)
      remote_debugging_version      = lookup(var.settings.site_config, "remote_debugging_version", null)

    }
  }

  app_settings = var.app_settings

  dynamic "connection_string" {
    for_each = var.connection_string

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  dynamic "auth_settings" {
    for_each = lookup(var.settings, "auth_settings", {}) != {} ? [1] : []

    content {
      enabled                        = lookup(var.settings.auth_settings, "enabled", false)
      additional_login_parameters    = lookup(var.settings.auth_settings, "additional_login_parameters", null)
      allowed_external_redirect_urls = lookup(var.settings.auth_settings, "allowed_external_redirect_urls", null)
      default_provider               = lookup(var.settings.auth_settings, "default_provider", null)
      issuer                         = lookup(var.settings.auth_settings, "issuer", null)
      runtime_version                = lookup(var.settings.auth_settings, "runtime_version", null)
      token_refresh_extension_hours  = lookup(var.settings.auth_settings, "token_refresh_extension_hours", null)
      token_store_enabled            = lookup(var.settings.auth_settings, "token_store_enabled", null)
      unauthenticated_client_action  = lookup(var.settings.auth_settings, "unauthenticated_client_action", null)

      dynamic "active_directory" {
        for_each = lookup(var.settings.auth_settings, "active_directory", {}) != {} ? [1] : []

        content {
          client_id         = var.settings.auth_settings.active_directory.client_id
          client_secret     = lookup(var.settings.auth_settings.active_directory, "client_secret", null)
          allowed_audiences = lookup(var.settings.auth_settings.active_directory, "allowed_audiences", null)
        }
      }

      dynamic "facebook" {
        for_each = lookup(var.settings.auth_settings, "facebook", {}) != {} ? [1] : []

        content {
          app_id       = var.settings.auth_settings.facebook.app_id
          app_secret   = var.settings.auth_settings.facebook.app_secret
          oauth_scopes = lookup(var.settings.auth_settings.facebook, "oauth_scopes", null)
        }
      }

      dynamic "google" {
        for_each = lookup(var.settings.auth_settings, "google", {}) != {} ? [1] : []

        content {
          client_id     = var.settings.auth_settings.google.client_id
          client_secret = var.settings.auth_settings.google.client_secret
          oauth_scopes  = lookup(var.settings.auth_settings.google, "oauth_scopes", null)
        }
      }

      dynamic "microsoft" {
        for_each = lookup(var.settings.auth_settings, "microsoft", {}) != {} ? [1] : []

        content {
          client_id     = var.settings.auth_settings.microsoft.client_id
          client_secret = var.settings.auth_settings.microsoft.client_secret
          oauth_scopes  = lookup(var.settings.auth_settings.microsoft, "oauth_scopes", null)
        }
      }

      dynamic "twitter" {
        for_each = lookup(var.settings.auth_settings, "twitter", {}) != {} ? [1] : []

        content {
          consumer_key    = var.settings.auth_settings.twitter.consumer_key
          consumer_secret = var.settings.auth_settings.twitter.consumer_secret
        }
      }
    }
  }

  dynamic "auth_settings_v2" {
    for_each = lookup(var.settings, "auth_settings_v2", {}) != {} ? [1] : []
    content {
      auth_enabled                            = lookup(var.settings.auth_settings_v2, "auth_enabled", false)
      runtime_version                         = lookup(var.settings.auth_settings_v2, "runtime_version", null)
      config_file_path                        = lookup(var.settings.auth_settings_v2, "config_file_path", null)
      require_authentication                  = lookup(var.settings.auth_settings_v2, "require_authentication", null)
      unauthenticated_action                  = lookup(var.settings.auth_settings_v2, "unauthenticated_action", null)
      default_provider                        = lookup(var.settings.auth_settings_v2, "default_provider", null)
      excluded_paths                          = lookup(var.settings.auth_settings_v2, "excluded_paths", null)
      require_https                           = lookup(var.settings.auth_settings_v2, "require_https", null)
      http_route_api_prefix                   = lookup(var.settings.auth_settings_v2, "http_route_api_prefix", null)
      forward_proxy_convention                = lookup(var.settings.auth_settings_v2, "forward_proxy_convention", null)
      forward_proxy_custom_host_header_name   = lookup(var.settings.auth_settings_v2, "forward_proxy_custom_host_header_name", null)
      forward_proxy_custom_scheme_header_name = lookup(var.settings.auth_settings_v2, "forward_proxy_custom_scheme_header_name", null)
      dynamic "login" {
        for_each = lookup(var.settings.auth_settings_v2, "login", {}) != {} ? [1] : []

        content {
          logout_endpoint                   = lookup(var.settings.auth_settings_v2.login, "logout_endpoint", null)
          token_store_enabled               = lookup(var.settings.auth_settings_v2.login, "token_store_enabled", null)
          token_refresh_extension_time      = lookup(var.settings.auth_settings_v2.login, "token_refresh_extension_time", null)
          token_store_path                  = lookup(var.settings.auth_settings_v2.login, "token_store_path", null)
          token_store_sas_setting_name      = lookup(var.settings.auth_settings_v2.login, "token_store_sas_setting_name", null)
          preserve_url_fragments_for_logins = lookup(var.settings.auth_settings_v2.login, "preserve_url_fragments_for_logins", null)
          allowed_external_redirect_urls    = lookup(var.settings.auth_settings_v2.login, "allowed_external_redirect_urls", null)
          cookie_expiration_convention      = lookup(var.settings.auth_settings_v2.login, "cookie_expiration_convention", null)
          cookie_expiration_time            = lookup(var.settings.auth_settings_v2.login, "cookie_expiration_time", null)
          validate_nonce                    = lookup(var.settings.auth_settings_v2.login, "validate_nonce", null)
          nonce_expiration_time             = lookup(var.settings.auth_settings_v2.login, "nonce_expiration_time", null)
        }
      }
      dynamic "apple_v2" {
        for_each = lookup(var.settings.auth_settings_v2, "apple_v2", {}) != {} ? [1] : []

        content {
          client_id                  = can(var.settings.auth_settings_v2.apple_v2.client_id_key) ? var.azuread_applications[try(var.settings.auth_settings_v2.apple_v2.client_id_lz_key, var.client_config.landingzone_key)][var.settings.auth_settings_v2.apple_v2.client_id_key].application_id : var.settings.auth_settings_v2.apple_v2.client_id
          client_secret_setting_name = var.settings.auth_settings_v2.apple_v2.client_secret_setting_name
          login_scopes               = lookup(var.settings.auth_settings_v2.apple_v2, "login_scopes", null)
        }
      }
      dynamic "azure_static_web_app_v2" {
        for_each = lookup(var.settings.auth_settings_v2, "azure_static_web_app_v2", {}) != {} ? [1] : []

        content {
          client_id = can(var.settings.auth_settings_v2.azure_static_web_app_v2.client_id_key) ? var.azuread_applications[try(var.settings.auth_settings_v2.azure_static_web_app_v2.client_id_lz_key, var.client_config.landingzone_key)][var.settings.auth_settings_v2.azure_static_web_app_v2.client_id_key].application_id : var.settings.auth_settings_v2.azure_static_web_app_v2.client_id
        }
      }
      dynamic "facebook_v2" {
        for_each = lookup(var.settings.auth_settings_v2, "facebook_v2_v2", {}) != {} ? [1] : []

        content {
          app_id                  = can(var.settings.auth_settings_v2.facebook_v2.app_id_key) ? var.azuread_applications[try(var.settings.auth_settings_v2.facebook_v2.app_id_lz_key, var.client_config.landingzone_key)][var.settings.auth_settings_v2.facebook_v2.app_id_key].application_id : var.settings.auth_settings_v2.facebook_v2.app_id
          app_secret_setting_name = var.settings.auth_settings_v2.facebook_v2.app_secret_setting_name
          graph_api_version       = lookup(var.settings.auth_settings_v2.facebook_v2, "graph_api_version", null)
          login_scopes            = lookup(var.settings.auth_settings_v2.facebook_v2, "login_scopes", null)
        }
      }
      dynamic "github_v2" {
        for_each = lookup(var.settings.auth_settings_v2, "github_v2", {}) != {} ? [1] : []
        content {
          client_id                  = can(var.settings.auth_settings_v2.github_v2.client_id_key) ? var.azuread_applications[try(var.settings.auth_settings_v2.github_v2.client_id_lz_key, var.client_config.landingzone_key)][var.settings.auth_settings_v2.github_v2.client_id_key].application_id : var.settings.auth_settings_v2.github_v2.client_id
          client_secret_setting_name = var.settings.auth_settings_v2.github_v2.client_secret_setting_name
          login_scopes               = lookup(var.settings.auth_settings_v2.github_v2, "login_scopes", null)
        }
      }
      dynamic "google_v2" {
        for_each = lookup(var.settings.auth_settings_v2, "google_v2", {}) != {} ? [1] : []

        content {
          client_id                  = can(var.settings.auth_settings_v2.google_v2.client_id_key) ? var.azuread_applications[try(var.settings.auth_settings_v2.google_v2.client_id_lz_key, var.client_config.landingzone_key)][var.settings.auth_settings_v2.google_v2.client_id_key].application_id : var.settings.auth_settings_v2.google_v2.client_id
          client_secret_setting_name = var.settings.auth_settings_v2.google_v2.client_secret_setting_name
          allowed_audiences          = lookup(var.settings.auth_settings_v2.google_v2, "allowed_audiences", null)
          login_scopes               = lookup(var.settings.auth_settings_v2.google_v2, "login_scopes", null)
        }
      }
      dynamic "microsoft_v2" {
        for_each = lookup(var.settings.auth_settings_v2, "microsoft_v2", {}) != {} ? [1] : []

        content {
          client_id                  = can(var.settings.auth_settings_v2.microsoft_v2.client_id_key) ? var.azuread_applications[try(var.settings.auth_settings_v2.microsoft_v2.client_id_lz_key, var.client_config.landingzone_key)][var.settings.auth_settings_v2.microsoft_v2.client_id_key].application_id : var.settings.auth_settings_v2.microsoft_v2.client_id
          client_secret_setting_name = var.settings.auth_settings_v2.microsoft_v2.client_secret_setting_name
          allowed_audiences          = lookup(var.settings.auth_settings_v2.microsoft_v2, "allowed_audiences", null)
          login_scopes               = lookup(var.settings.auth_settings_v2.microsoft_v2, "login_scopes", null)
        }
      }
      dynamic "twitter_v2" {
        for_each = lookup(var.settings.auth_settings_v2, "twitter_v2", {}) != {} ? [1] : []

        content {
          consumer_key                 = var.settings.auth_settings_v2.twitter_v2.consumer_key
          consumer_secret_setting_name = var.settings.auth_settings_v2.twitter_v2.consumer_secret
        }
      }
      dynamic "active_directory_v2" {
        for_each = lookup(var.settings.auth_settings_v2, "active_directory_v2", {}) != {} ? [1] : []

        content {
          client_id                       = can(var.settings.auth_settings_v2.active_directory_v2.client_id_key) ? var.azuread_applications[try(var.settings.auth_settings_v2.active_directory_v2.client_id_lz_key, var.client_config.landingzone_key)][var.settings.auth_settings_v2.active_directory_v2.client_id_key].application_id : var.settings.auth_settings_v2.active_directory_v2.client_id
          tenant_auth_endpoint            = var.settings.auth_settings_v2.active_directory_v2.tenant_auth_endpoint
          client_secret_setting_name      = can(var.settings.auth_settings_v2.active_directory_v2.client_secret_setting_name_key) ? var.azuread_service_principal_passwords[try(var.settings.auth_settings_v2.active_directory_v2.client_secret_setting_name.lz_key, var.client_config.landingzone_key)][var.settings.auth_settings_v2.active_directory_v2.client_secret_setting_name.key].service_principal_password : try(var.settings.auth_settings_v2.active_directory_v2.client_secret_setting_name, null)
          allowed_audiences               = lookup(var.settings.auth_settings_v2.active_directory_v2, "allowed_audiences", null)
          jwt_allowed_groups              = lookup(var.settings.auth_settings_v2.active_directory_v2, "jwt_allowed_groups ", null)
          jwt_allowed_client_applications = lookup(var.settings.auth_settings_v2.active_directory_v2, "jwt_allowed_client_applications ", null)
          www_authentication_disabled     = lookup(var.settings.auth_settings_v2.active_directory_v2, "www_authentication_disabled  ", null)
          allowed_groups                  = lookup(var.settings.auth_settings_v2.active_directory_v2, "allowed_groups", null)
          allowed_identities              = lookup(var.settings.auth_settings_v2.active_directory_v2, "allowed_identities", null)
          allowed_applications            = lookup(var.settings.auth_settings_v2.active_directory_v2, "allowed_applications", null)
          login_parameters                = lookup(var.settings.auth_settings_v2.active_directory_v2, "login_parameters", null)
        }
      }
    }
  }

  dynamic "storage_account" {
    for_each = try(var.settings.storage_account, {})
    content {
      name         = var.settings.storage_account.name
      type         = var.settings.storage_account.type
      account_name = can(var.settings.storage_account.account_key) ? var.settings.storage_account.account_key : var.storage_accounts[try(var.settings.storage_account.lz_key, var.client_config.landingzone_key)][var.settings.storage_account.access_key].account
      share_name   = var.settings.storage_account.share_name
      access_key   = can(var.settings.storage_account.account_key) ? var.settings.storage_account.account_key : var.storage_accounts[try(var.settings.storage_account.lz_key, var.client_config.landingzone_key)][var.settings.storage_account.access_key].primary_access_key
      mount_path   = try(var.settings.storage_account.mount_path, null)
    }
  }

  dynamic "backup" {
    for_each = lookup(var.settings, "backup", {}) != {} ? [1] : []

    content {
      name                = var.settings.backup.name
      enabled             = var.settings.backup.enabled
      storage_account_url = try(var.settings.backup.storage_account_url, local.backup_sas_url)

      dynamic "schedule" {
        for_each = lookup(var.settings.backup, "schedule", {}) != {} ? [1] : []

        content {
          frequency_interval       = var.settings.backup.schedule.frequency_interval
          frequency_unit           = lookup(var.settings.backup.schedule, "frequency_unit", null)
          keep_at_least_one_backup = lookup(var.settings.backup.schedule, "keep_at_least_one_backup", null)
          retention_period_days    = lookup(var.settings.backup.schedule, "retention_period_days", null)
          start_time               = lookup(var.settings.backup.schedule, "start_time", null)
        }
      }
    }
  }

  dynamic "logs" {
    for_each = lookup(var.settings, "logs", {}) != {} ? [1] : []

    content {
      detailed_error_messages = try(var.settings.logs.detailed_error_messages, null)
      failed_request_tracing  = try(var.settings.logs.failed_request_tracing, null)

      dynamic "application_logs" {
        for_each = lookup(var.settings.logs, "application_logs", {}) != {} ? [1] : []

        content {
          file_system_level = try(var.settings.logs.application_logs.file_system_level, null)

          dynamic "azure_blob_storage" {
            for_each = lookup(var.settings.logs.application_logs, "azure_blob_storage", {}) != {} ? [1] : []

            content {
              level             = var.settings.logs.application_logs.azure_blob_storage.level
              sas_url           = try(var.settings.logs.application_logs.azure_blob_storage.sas_url, local.logs_sas_url)
              retention_in_days = var.settings.logs.application_logs.azure_blob_storage.retention_in_days
            }
          }
        }
      }

      dynamic "http_logs" {
        for_each = lookup(var.settings.logs, "http_logs", {}) != {} ? [1] : []

        content {
          dynamic "azure_blob_storage" {
            for_each = lookup(var.settings.logs.http_logs, "azure_blob_storage", {}) != {} ? [1] : []

            content {
              sas_url           = try(var.settings.logs.http_logs.azure_blob_storage.sas_url, local.http_logs_sas_url)
              retention_in_days = var.settings.logs.http_logs.azure_blob_storage.retention_in_days
            }
          }
          dynamic "file_system" {
            for_each = lookup(var.settings.logs.http_logs, "file_system", {}) != {} ? [1] : []

            content {
              retention_in_days = var.settings.logs.http_logs.file_system.retention_in_days
              retention_in_mb   = var.settings.logs.http_logs.file_system.retention_in_mb
            }
          }
        }
      }
    }
  }

  # lifecycle {
  #   ignore_changes = [
  #     app_settings["WEBSITE_RUN_FROM_PACKAGE"],
  #     site_config[0].scm_type
  #   ]
  # }
}
