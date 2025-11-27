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
  # Calcul automatique du sous-domaine par soustraction
  subdomain_for_txt = trim(
    replace(
      replace(var.settings.host_name, "${var.remote_objects.dns_zones[try(var.settings.dns_zone.lz_key, var.client_config.landingzone_key)][var.settings.dns_zone.key].name}.", ""),
      ".", "", # Enlève le dernier point s'il reste
    ),
    "."
  )
}