// Version Information
terraform {
  required_version = ">= 0.15"
  required_providers {
    volterra = {
      source = "volterraedge/volterra"
      version = "0.11.14"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.8.0"
    }
    /* Needed for cron issue */
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}