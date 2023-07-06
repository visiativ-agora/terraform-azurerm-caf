variable "global_settings" {
  description = "Global settings object (see module README.md)"
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
}

variable "tags" {
  description = "Tags to be used for this resource deployment."
  type        = map(any)
  default     = {}
}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
  default     = {}
}

variable "name" {
  description = "(Required) The name of the PowerBI Embedded. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}

variable "scope" {
  description = "(Required) The scope of the Maintenance Configuration. Possible values are Extension, Host, InGuestPatch, OSImage, SQLDB or SQLManagedInstance."
  type        = string
  validation {
    condition     = contains(["Extension", "Host", "InGuestPatch", "OSImage", "SQLDB", "SQLManagedInstance"], var.scope)
    error_message = "Invalid value for scope. Possible values are Extension, Host, InGuestPatch, OSImage, SQLDB or SQLManagedInstance."
  }
}

variable "visibility" {
  description = "The visibility of the Maintenance Configuration."
  type        = string
  default     = null
}

variable "properties" {
  description = "A mapping of properties to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "Resource group object"
}

variable "window" {}

#variable "install_patches" {}

variable "install_patches" {
  description = "Install patches configuration."
  type        = map(any)
  default     = null
  validation {
    condition = (
      can(var.install_patches.linux) &&
      can(var.install_patches.windows) &&
      can(var.install_patches.reboot) &&
      contains(["Always", "IfRequired", "Never"], var.install_patches.reboot) &&
      can(var.install_patches.windows.classifications_to_include) &&
      contains(["Critical", "Security", "UpdateRollup", "FeaturePack", "ServicePack", "Definition", "Tools", "Updates"], var.install_patches.windows.classifications_to_include) &&
      can(var.install_patches.linux.classifications_to_include) &&
      contains(["Critical", "Security", "Other"], var.install_patches.windows.classifications_to_include)
    )
    error_message = "The 'install_patches' must be specified when 'scope' is set to 'InGuestPatch' and it should include valid configuration."
  }
}

variable "settings" {}

variable "in_guest_user_patch_mode" {
  description = "The in guest user patch mode."
  type        = string
  default     = null
}


