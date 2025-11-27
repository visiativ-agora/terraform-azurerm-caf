# This file is maintained for legacy purposes. Please do not modify this file.
terraform {
  required_providers {
    azurecaf = {
      source = "aztfmod/azurecaf"
    }
  }
}
# locals {
#   domain_parts      = split(".", var.settings.host_name)
#   subdomain_for_txt = local.domain_parts[0]
# }


locals {
  # Récupère la zone DNS exacte
  zone_name = try(var.settings.dns_zone.lz_key, null) == null ? var.remote_objects.dns_zones[var.client_config.landingzone_key][var.settings.dns_zone.key].name : var.remote_objects.dns_zones[var.settings.dns_zone.lz_key][var.settings.dns_zone.key].name

  # Soustrait la zone du hostname pour garder le sous-domaine
  subdomain_for_txt = trim(
    replace(var.settings.host_name, ".${local.zone_name}", ""), "."
  )
}