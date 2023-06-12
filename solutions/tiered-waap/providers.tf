terraform {
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.21"
    }
  }
}

provider "volterra" {
  url          = var.volterra_url
  api_p12_file = var.volterra_p12_file
}
