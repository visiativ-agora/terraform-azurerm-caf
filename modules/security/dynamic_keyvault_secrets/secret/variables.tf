variable "name" {}
variable "value" {}
variable "keyvault_id" {}
variable "tags" {
  type    = map(string)
  default = {}
}