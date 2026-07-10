terraform {
  required_providers {
    vmworkstation = {
      source  = "elsudano/vmworkstation"
      version = "1.0.4"
    }
  }
  required_version = ">= 1.0.0"
}

provider "vmworkstation" {
  url      = "http://127.0.0.1:8697/api"
  user     = var.vmware_user
  password = var.vmware_password
  https    = false
  debug    = false
}