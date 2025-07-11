terraform {
  required_providers {
    azurecaf = {
      source = "aztfmod/azurecaf"
    }
  }

}

locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  # tags = merge(var.base_tags, local.module_tag, try(var.tags, null))
  # location            = var.location
  # resource_group_name = var.resource_group_name
}

locals {
  # On "aplatit" la map des membres pour pouvoir faire un for_each dessus
  fleet_members = flatten([
    for member_name, member in var.settings : [
      for key_obj in member.keys : {
        name      = member_name
        lz_key    = key_obj.lz_key
        key       = key_obj.keys[0] # On suppose qu'il n'y a qu'un seul key par keys
      }
    ]
  ])
}
