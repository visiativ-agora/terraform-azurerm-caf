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


variable "settings" {}


variable "policy_definition_id" {
  description = "(Required) The ID of the Policy Definition or Policy Definition Set. Changing this forces a new Policy Assignment to be created."
}
variable "subscription_id" {
  description = "(Required) The ID of the Subscription where this Policy Assignment should be created. Changing this forces a new Policy Assignment to be created."
}
variable "description" {
  description = "(Optional) A description which should be used for this Policy Assignment."
}
variable "display_name" {
  description = "(Optional) The Display Name for this Policy Assignment."
}
variable "enforce" {
  description = "(Optional) Specifies if this Policy should be enforced or not? Defaults to true"
}
variable "identity" {}
variable "location" {
  description = "(Optional) The Azure Region where the Policy Assignment should exist. Changing this forces a new Policy Assignment to be created."
}
variable "metadata" {
  description = "(Optional) A JSON mapping of any Metadata for this Policy."
}
# variable "non_compliance_message" {
#   description = "(Optional) One or more non_compliance_message blocks as defined below."
# }
variable "not_scopes" {
  description = "(Optional) Specifies a list of Resource Scopes (for example a Subscription, or a Resource Group) within this Management Group which are excluded from this Policy."
}
variable "parameters" {
  description = "(Optional) A JSON mapping of any Parameters for this Policy."
}
# variable "overrides" {
#   description = "(Optional) One or more overrides blocks as defined below. More detail about overrides and resource_selectors"
# }
# variable "resource_selectors" {
#   description = "(Optional) One or more resource_selectors blocks as defined below to filter polices by resource properties."
# }