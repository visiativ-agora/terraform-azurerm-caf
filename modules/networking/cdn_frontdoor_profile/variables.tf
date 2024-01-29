variable "global_settings" {
  description = "Global settings object (see module README.md)"
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
}
variable "settings" {
  description = "(Required) Used to handle passthrough paramenters."
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
  default     = {}
}
variable "tags" {
  description = "Tags to be used for this resource deployment."
  type        = map(any)
  default     = {}
}
variable "resource_group_name" {
  description = " The name of the resource group in which to"
}
variable "sku_name" {
  description = "(Required) Specifies the SKU for this Front Door Profile. Possible values include Standard_AzureFrontDoor and Premium_AzureFrontDoor. Changing this forces a new resource to be created."
}
variable "name" {
  description = "(Required) Specifies the name of the Front Door Profile. Changing this forces a new resource to be created."
  type        = string
}