module "cdn_endpoint" {
  source   = "./modules/networking/cdn_endpoint"
  for_each = local.networking.cdn_endpoint

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  location            = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name

  remote_objects = {
    profile_name = can(each.value.profile.name) ? each.value.profile.name : local.combined_objects_cdn_profile[try(each.value.profile.lz_key, local.client_config.landingzone_key)][each.value.profile.key].name
  }
}

output "cdn_endpoint" {
  value = module.cdn_endpoint
}

module "cdn_profile" {
  source   = "./modules/networking/cdn_profile"
  for_each = local.networking.cdn_profile

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  name            = each.value.name

  location            = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name

  remote_objects = {
    diagnostics = local.combined_diagnostics
  }
}
output "cdn_profile" {
  value = module.cdn_profile
}
#
#
# Azure Front Door Profile
#
#
module "cdn_frontdoor_profile" {
  source   = "./modules/networking/cdn_frontdoor_profile"
  for_each = local.networking.cdn_frontdoor_profile

  global_settings           = local.global_settings
  client_config             = local.client_config
  settings                  = each.value
  name                      = each.value.name
  resource_group_name       = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name  
  sku_name                  = each.value.sku_name
  tags                      = try(each.value.tags, {})
}

output "cdn_frontdoor_profile" {
  value = module.cdn_frontdoor_profile
}
#
#
# Azure Front Door Endpoint
#
#
# module "cdn_frontdoor_endpoint" {
#   source   = "./modules/networking/cdn_frontdoor_endpoint"
#   for_each = local.networking.cdn_frontdoor_endpoint

#   global_settings           = local.global_settings
#   client_config             = local.client_config
#   settings                  = each.value
#   name                      = each.value.name
#   cdn_frontdoor_profile_id  = can(each.value.cdn_frontdoor_profile_id) ? each.value.cdn_frontdoor_profile_id : local.combined_objects_cdn_frontdoor_profile[try(each.value.lz_key, local.client_config.landingzone_key)][each.value._cdn_frontdoor_profile_key].id
#   enabled                   = try(each.value.enabled, null)
#   tags                      = try(each.value.tags, {})
# }

# output "cdn_frontdoor_endpoint" {
#   value = module.cdn_frontdoor_endpoint
# }
# #
# #
# # Azure Front Door Origin Group
# #
# #
# module "cdn_frontdoor_origin_group" {
#   source   = "./modules/networking/cdn_frontdoor_origin_group"
#   for_each = local.networking.cdn_frontdoor_origin_group

#   global_settings                                             = local.global_settings
#   client_config                                               = local.client_config
#   settings                                                    = each.value
#   name                                                        = each.value.name
#   cdn_frontdoor_profile_id                                    = can(each.value.cdn_frontdoor_profile_id) ? each.value.cdn_frontdoor_profile_id : local.combined_objects_cdn_frontdoor_profile[try(each.value.lz_key, local.client_config.landingzone_key)][each.value._cdn_frontdoor_profile_key].id
#   session_affinity_enabled                                    = try(each.value.session_affinity_enabled, null)
#   restore_traffic_time_to_healed_or_new_endpoint_in_minutes   = try(each.value.restore_traffic_time_to_healed_or_new_endpoint_in_minutes, null)
#   health_probe                                                = try(each.value.health_probe, null)
#   load_balancing                                              = each.value.load_balancing
# }

# output "cdn_frontdoor_origin_group" {
#   value = module.cdn_frontdoor_origin_group
# }
# #
# #
# # Azure Front Door Origin
# #
# #
# module "cdn_frontdoor_origin" {
#   source   = "./modules/networking/cdn_frontdoor_origin"
#   for_each = local.networking.cdn_frontdoor_origin

#   global_settings                                             = local.global_settings
#   client_config                                               = local.client_config
#   settings                                                    = each.value
#   name                                                        = each.value.name
#   cdn_frontdoor_origin_group_id                               = can(each.value.cdn_frontdoor_origin_group_id) ? each.value.cdn_frontdoor_origin_group_id : local.combined_objects_cdn_frontdoor_origin_group[try(each.value.lz_key, local.client_config.landingzone_key)][each.value._cdn_frontdoor_origin_group_key].id
#   enabled                                                     = try(each.value.enabled, null)
#   certificate_name_check_enabled                              = each.value.certificate_name_check_enabled
#   host_name                                                   = each.value.host_name
#   http_port                                                   = try(each.value.http_port, null)
#   https_port                                                  = try(each.value.https_port, null)
#   origin_host_header                                          = try(each.value.origin_host_header, null)
#   priority                                                    = try(each.value.priority, null)
#   weight                                                      = try(each.value.weight, null)
#   private_link                                                = try(each.value.private_link, null)
# }

# output "cdn_frontdoor_origin" {
#   value = module.cdn_frontdoor_origin
# }
# #
# #
# # Azure Front Custom Domain
# #
# #
# module "cdn_frontdoor_custom_domain" {
#   source   = "./modules/networking/cdn_frontdoor_custom_domain"
#   for_each = local.networking.cdn_frontdoor_custom_domain

#   global_settings                                             = local.global_settings
#   client_config                                               = local.client_config
#   settings                                                    = each.value
#   name                                                        = each.value.name  
#   cdn_frontdoor_profile_id                                    = can(each.value.cdn_frontdoor_profile_id) ? each.value.cdn_frontdoor_profile_id : local.combined_objects_cdn_frontdoor_profile[try(each.value.lz_key, local.client_config.landingzone_key)][each.value._cdn_frontdoor_profile_key].id
#   host_name                                                   = each.value.host_name
#   dns_zone_id                                                 = try(each.value.dns_zone.lz_key, null) == null ? local.combined_objects_dns_zones[local.client_config.landingzone_key][each.value.dns_zone.key].id : local.combined_objects_dns_zones[each.value.dns_zone.lz_key][each.value.dns_zone.key].id
#   tls                                                         = each.value.https_port
# }

# output "cdn_frontdoor_custom_domain" {
#   value = module.cdn_frontdoor_custom_domain
# }
# #
# #
# # Azure Front Door Route
# #
# #
# module "cdn_frontdoor_route" {
#   source   = "./modules/networking/cdn_frontdoor_route"
#   for_each = local.networking.cdn_frontdoor_route

#   global_settings                                             = local.global_settings
#   client_config                                               = local.client_config
#   settings                                                    = each.value
#   name                                                        = each.value.name  
#   enabled                                                     = try(each.value.enabled, null) 
#   cdn_frontdoor_endpoint_id                                   = can(each.value.cdn_frontdoor_endpoint_id) ? each.value.cdn_frontdoor_endpoint_id : local.combined_objects_cdn_frontdoor_endpoint[try(each.value.lz_key, local.client_config.landingzone_key)][each.value.cdn_frontdoor_endpoint_key].id
#   cdn_frontdoor_origin_group_id                               = can(each.value.cdn_frontdoor_origin_group_id) ? each.value.cdn_frontdoor_origin_group_id : local.combined_objects_frontdoor_origin_group[try(each.value.lz_key, local.client_config.landingzone_key)][each.value.frontdoor_origin_group_key].id
#   cdn_frontdoor_origin_ids                                    = can(each.value.cdn_frontdoor_origin_ids) ? each.value.cdn_frontdoor_origin_ids : local.cdn_frontdoor_origin[try(each.value.lz_key, local.client_config.landingzone_key)][each.value.cdn_frontdoor_origin_key].id
#   cdn_frontdoor_rule_set_ids                                  = can(each.value.cdn_frontdoor_rule_set_ids) ? each.value.cdn_frontdoor_rule_set_ids : local.combined_objects_cdn_frontdoor_rule_set[try(each.value.lz_key, local.client_config.landingzone_key)][each.value.cdn_frontdoor_rule_set_key].id
#   forwarding_protocol                                         = each.value.forwarding_protocol
#   patterns_to_match                                           = each.value.patterns_to_match
#   supported_protocols                                         = each.value.supported_protocols
#   cache                                                       = try(each.value.cache, null)
#   https_redirect_enabled                                      = try(each.value.https_redirect_enabled, null)
#   link_to_default_domain                                      = try(each.value.link_to_default_domain, null)
# }

# output "cdn_frontdoor_route" {
#   value = module.cdn_frontdoor_route
# }
# #
# #
# # Azure Front Door Rule Set
# #
# #
# module "cdn_frontdoor_rule_set" {
#   source   = "./modules/networking/cdn_frontdoor_rule_set"
#   for_each = local.networking.cdn_frontdoor_rule_set

#   global_settings                                             = local.global_settings
#   client_config                                               = local.client_config
#   settings                                                    = each.value
#   name                                                         = each.value.name
#   cdn_frontdoor_profile_id                                    = can(each.value.cdn_frontdoor_profile_id) ? each.value.cdn_frontdoor_profile_id : local.combined_objects_cdn_frontdoor_profile[try(each.value.lz_key, local.client_config.landingzone_key)][each.value._cdn_frontdoor_profile_key].id
  
# }

# output "cdn_frontdoor_rule_set" {
#   value = module.cdn_frontdoor_rule_set
# }
# #
# #
# # Azure Front Door Rule
# #
# #
# module "cdn_frontdoor_rule" {
#   source   = "./modules/networking/cdn_frontdoor_rule"
#   for_each = {
#     for key, value in var.cdn_frontdoor_rule_set : key => value
#     if can(value.rules)
#   }

#   client_config      = local.client_config
#   settings           = each.value
#   cdn_frontdoor_rule_set_id = module.cdn_frontdoor_rule_set[each.key].id
# }
