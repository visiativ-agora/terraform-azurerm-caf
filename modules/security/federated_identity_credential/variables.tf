
variable "name" {}

variable "global_settings" {
  description = "Global settings object (see module README.md)"
}

variable "resource_group_name" {
  description = "Name of the existing resource group to deploy the resource"
}

variable "audience" {}

variable "issuer" {}

variable "parent_id" {}

variable "subject" {}