kubernetes_fleet_managers = {
  afm1 = {
    name = "aks-fleet-manager-re1"
    resource_group = {
      key = "aks_re1"
    }
    members = {
      cluster_a = {
        # lz_key = ""
        key    = "cluster_re1"
        group  = "dev" # Optionnal
      }
    }    
  }
}

