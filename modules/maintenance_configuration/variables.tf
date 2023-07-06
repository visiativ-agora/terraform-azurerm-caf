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

variable "linux_package_names_mask_to_include" {
  description = "List of package names to be included for patching (Linux)."
  type        = list(string)
  default     = null
}

variable "windows_classifications_to_include" {
  description = "List of Classification category of patches to be patched (Windows)."
  type        = list(string)
  default     = null
}

variable "windows_kb_numbers_to_exclude" {
  description = "List of KB numbers to be excluded from patching (Windows)."
  type        = list(string)
  default     = null
}

variable "windows_kb_numbers_to_include" {
  description = "List of KB numbers to be included for patching (Windows)."
  type        = list(string)
  default     = null
}

variable "resource_group_name" {
  description = "Resource group object"
}

variable "window" {}
variable "install_patches" {}
variable "settings" {}

variable "in_guest_user_patch_mode" {
  description = "The in guest user patch mode."
  type        = string
  default     = null
  validation {
    condition     = var.in_guest_user_patch_mode != null && var.scope == "InGuestPatch"
    error_message = "The 'in_guest_user_patch_mode' must be specified when 'scope' is set to 'InGuestPatch'."
  }
}

variable "in_guest_user_patch_mode" {
  description = "The in guest user patch mode."
  type        = string
  default     = null
  validation {
    condition     = var.in_guest_user_patch_mode != null && dummy_scope == "InGuestPatch"
    error_message = "The 'in_guest_user_patch_mode' must be specified when 'scope' is set to 'InGuestPatch'."
  }
}

variable "dummy_scope" {
  description = "Dummy scope variable for validation condition"
  default     = "InGuestPatch"
}

