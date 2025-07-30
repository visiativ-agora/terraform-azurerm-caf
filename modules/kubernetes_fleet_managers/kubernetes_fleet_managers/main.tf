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
  tags = merge(var.base_tags, local.module_tag, try(var.tags, null))
  location            = var.location
  resource_group_name = var.resource_group_name
}


# locals {
#   fleet_members = length(try(var.settings.members_groups, {})) > 0 ? merge(
#     {
#       for group_key, group in try(var.settings.members_groups, {}) :
#       group_key => {
#         for member_key, member in try(group.members, {}) :
#         member_key => merge(
#           member,
#           {
#             group_key   = group_key
#             member_key  = member_key
#           }
#         )
#       }
#     }
#   ) : {}
# }

locals {
  members_groups_list = flatten([
    for group_key, group in try(var.settings.members_groups, {}) : [
      for member_key, member in try(group.members, {}) : merge(
        member,
        {
          group_key  = group_key
          member_key = member_key
        }
      )
    ]
  ])

  fleet_members = length(local.members_groups_list) > 0 ? {
      for idx, member in local.members_groups_list :
      "${member.group_key}.${member.member_key}" => member
    } : {}
}



