variable "kubernetes_fleet_id" {
  description = "(Required) Specifies the Kubernetes Fleet Id within which this Kubernetes Fleet Member should exist. Changing this forces a new Kubernetes Fleet Member to be created."
} 
variable "kubernetes_cluster_id" {
  description = "(Required) The ARM resource ID of the cluster that joins the Fleet. Changing this forces a new Kubernetes Fleet Member to be created."
} 
variable "global_settings" {
  description = "Global settings object (see module README.md)"
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
}
variable "settings" {}

variable "members" {
  description = "Liste des membres à ajouter (lz_key + cluster key)"
  type = list(object({
    lz_key = string
    keys   = string
  }))
}