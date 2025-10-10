# This file is maintained for legacy purposes. Please do not modify this file.
terraform {
  required_providers {
    azurecaf = {
      source = "aztfmod/azurecaf"
    }
  }
}
locals {
  domain_parts      = split(".", var.settings.host_name)
  subdomain_for_txt = local.domain_parts[0]
}
