terraform {
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.21"
    }
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.4.0"
    }
  }
}

provider "volterra" {
  url          = var.volterra_url
  api_p12_file = var.volterra_p12_file
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}
