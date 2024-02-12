global_settings = {
  random_length  = "5"
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
}

resource_groups = {
  rg1 = {
    name = "front-door-rg"
  }
}

cdn_frontdoor_profiles = {
  f1_profile = {
    name               = "frontdoor-rg1"
    resource_group_key = "rg1"
    # resource_group = {
    #     lz_key = xxx
    #     key = xxx
    # }
    sku_name         = "Premium_AzureFrontDoor"
    response_timeout = 120
    #tags = {}
    secrets = {
      cert1 = {
        keyvault_key = ""
        cert_key     = ""
      }
      cert2 = {
        cert_id = ""
      }
    }
    domains = {
      d1 = {
        name = "dev1"
        fqdn = "consoto"
        dns_zone = {
          lz_key = ""
          key    = ""
        }
        # dns_zone_id = "subscription/..."
        tls = {
          certificate_type    = "ManagedCertificate"
          minimum_tls_version = "TLS12"
        }
      }
      d2 = {
        name = "dev2"
        fqdn = "consoto"
        # dns_zone_id = "subscription/..."
        tls = {
          certificate_type    = "CustomerCertificate"
          minimum_tls_version = "TLS12"
          secret_key          = "cert2"
        }

      }
    }
    endpoints = {
      ep1 = {
        name    = "web"
        enabled = true
        #tags = {}
      }
    }
  }
}

cdn_frontdoor_origin_groups = {
  og1 = {
    name                                             = "app1-dev"
    restore_traffic_time_to_healed_or_new_endpoint_m = 10
    session_affinity                                 = true
    health_probe = {
      interval_s   = 60
      path         = "/"
      protocol     = "Https"
      request_type = "HEAD"
    }
    load_balancing = {
      successful_samples_required = 3
      sample_size                 = 4
      additionnal_latency_ms      = 50
    }
    routes = {
      route1 = {
        name                  = "route1"
        enabled               = true
        frontdoor_endpoint_id = "/subscription/..."
        frontdoor_endpoint = {
          # lz_key = "hub"
          profile_key = "f1_profile"
          key         = "ep1"
        }
        origin_keys = ["o1", "o2"]
        rules_sets_keys = {
          rs1 = {
            # lz_key = ""
            key = "set1"
          }
        }
        forwarding_protocol    = "HttpsOnly"
        https_redirect_enabled = true
        patterns_to_match      = ["/*"]
        supported_protocols    = ["Http", "Https"]
        # Passer par l'association
        domains_keys = {
          d1 = {
            # lz_key = ""
            profile_key = "f1_profile"
            key         = "d1"
          }
        }
        link_to_default_domain = false
        origin_path            = "/login"
        cache = {
          query_string_caching_behavior = "IgnoreSpecifiedQueryStrings"
          query_strings                 = ["account", "settings"]
          compression_enabled           = true
          content_types_to_compress = [
            "application/eot",
            "application/font",
            "application/font-sfnt",
            "application/javascript",
            "application/json",
            "application/opentype",
            "application/otf",
            "application/pkcs7-mime",
            "application/truetype",
            "application/ttf",
            "application/vnd.ms-fontobject",
            "application/xhtml+xml",
            "application/xml",
            "application/xml+rss",
            "application/x-font-opentype",
            "application/x-font-truetype",
            "application/x-font-ttf",
            "application/x-httpd-cgi",
            "application/x-mpegurl",
            "application/x-opentype",
            "application/x-otf",
            "application/x-perl",
            "application/x-ttf",
            "application/x-javascript",
            "font/eot",
            "font/ttf",
            "font/otf",
            "font/opentype",
            "image/svg+xml",
            "text/css",
            "text/csv",
            "text/html",
            "text/javascript",
            "text/js",
            "text/plain",
            "text/richtext",
            "text/tab-separated-values",
            "text/xml",
            "text/x-script",
            "text/x-component",
            "text/x-java-source",
          ]
        }
      }

    }
    origins = {
      o1 = {
        name                           = "app1-dev"
        hostname                       = "www.app1-dev.com"
        origin_host_header             = nil
        enabled                        = true
        certificate_name_check_enabled = false
        ports = {
          http  = 80
          https = 443
        }
        priority = 1
        weight   = 500
        private_link = {
          target_type = nil // (Optional) Specifies the type of target for this Private Link Endpoint. Possible values are blob, blob_secondary, web and sites.
          location    = "francecentral"
          # private_link_target_id = "/subscription/..."
          private_link_target = {
            lz_key = "hub"
            key    = "f1_profile"
          }
        }
      }
      o2 = {
        name                           = "app2-dev"
        hostname                       = "www.app2-dev.com"
        origin_host_header             = nil
        enabled                        = true
        certificate_name_check_enabled = false
        ports = {
          http  = 80
          https = 443
        }
        priority = 1
        weight   = 500
        private_link = {
          target_type = nil // (Optional) Specifies the type of target for this Private Link Endpoint. Possible values are blob, blob_secondary, web and sites.
          location    = "francecentral"
          # private_link_target_id = "/subscription/..."
          private_link_target = {
            lz_key = "hub"
            key    = "f1_profile"
          }
        }
      }
    }
  }
}

cdn_frontdoor_rules_sets = {
  set1 = {
    name = "exampleruleset1"
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule
    rules = {
      r1 = {
        name              = "examplerule1"
        order             = 1
        behavior_on_match = "Continue"
        actions = {
          response_header_actions = {
            rha1 = {
              header_action = "Overwrite"
              header_name   = "Access-Control-Allow-Origin"
              value         = "https://www.foo.bar.fr"
            }
          }
          # url_redirect_actions                 = {}
          # route_configuration_override_actions = {}
          # request_header_actions               = {}
          # url_rewrite_actions                  = {}
        }
        conditions = {
          is_device_conditions = {
            idc1 = {
              operator     = "Equal"
              match_values = ["Desktop"]
            }
          }
          # remote_address_conditions     = {}
          # request_method_conditions     = {}
          # query_string_conditions       = {}
          # post_args_conditions          = {}
          # request_uri_conditions        = {}
          # request_header_conditions     = {}
          # request_body_conditions       = {}
          # request_scheme_conditions     = {}
          # url_path_conditions           = {}
          # url_file_extension_conditions = {}
          # url_filename_conditions       = {}
          # http_version_conditions       = {}
          # cookies_conditions            = {}
          # is_device_conditions          = {}
          # socket_address_conditions     = {}
          # client_port_conditions        = {}
          # server_port_conditions        = {}
          # host_name_conditions          = {}
          # ssl_protocol_conditions       = {}
        }
      }
    }
  }
}
