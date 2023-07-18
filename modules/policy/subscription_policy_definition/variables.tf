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

variable "settings" {}


variable "policy_type" {
  description = "Required) The policy type. Possible values are BuiltIn, Custom, NotSpecified and Static. Changing this forces a new resource to be created."
  default     = "BuiltIn"
  type        = string

  validation {
    condition     = contains(["BuiltIn", "Custom", "NotSpecified", "Static"], var.policy_type)
    error_message = "Provide a valid value for policy type."
  }
}
variable "mode" {
  description = "(Required) The policy resource manager mode that allows you to specify which resource types will be evaluated. Possible values are All, Indexed, Microsoft.ContainerService.Data, Microsoft.CustomerLockbox.Data, Microsoft.DataCatalog.Data, Microsoft.KeyVault.Data, Microsoft.Kubernetes.Data, Microsoft.MachineLearningServices.Data, Microsoft.Network.Data and Microsoft.Synapse.Data."
  default     = "All"
  type        = string

  validation {
    condition     = contains(["All", "Indexed", "Microsoft.ContainerService.Data", "Microsoft.CustomerLockbox.Data", "Microsoft.DataCatalog.Data", "Microsoft.KeyVault.Data", "Microsoft.Kubernetes.Data", "Microsoft.MachineLearningServices.Data", "Microsoft.Network.Data", "Microsoft.Synapse.Data"], var.mode)
    error_message = "Provide a valid value for mode."
  }
}
variable "description" {
  description = "(Optional) The description of the policy definition."
}
variable "display_name" {
  description = "(Required) The display name of the policy definition."
}
variable "management_group_id" {
  description = "(Optional) The id of the Management Group where this policy should be defined. Changing this forces a new resource to be created."
}
variable "policy_rule" {
  description = "(Optional) The policy rule for the policy definition. This is a JSON string representing the rule that contains an if and a then block."
}
variable "metadata" {
  description = "(Optional) The metadata for the policy definition. This is a JSON string representing additional metadata that should be stored with the policy definition."
}
variable "parameters" {
  description = "(Optional) Parameters for the policy definition. This field is a JSON string that allows you to parameterize your policy definition."
}
