locals {
  ca_certs = {
    cluster_ca_certificate = base64decode(module.f5xc.app_kubecfg_cluster_ca)
    client_certificate     = base64decode(module.f5xc.app_kubecfg_client_cert)
    client_key             = base64decode(module.f5xc.app_kubecfg_client_key)
  }
}

provider "volterra" {
  api_p12_file = "${path.root}/creds/${var.api_p12_file}"
  url          = var.api_url
  timeout      = "120s"
}

provider "kubernetes" {
  alias                  = "app"
  host                   = module.f5xc.app_kubecfg_host
  cluster_ca_certificate = local.ca_certs.cluster_ca_certificate
  client_certificate     = local.ca_certs.client_certificate
  client_key             = local.ca_certs.client_key
}

provider "kubernetes" {
  alias                  = "utility"
  host                   = module.f5xc.utility_kubecfg_host
  cluster_ca_certificate = local.ca_certs.cluster_ca_certificate
  client_certificate     = local.ca_certs.client_certificate
  client_key             = local.ca_certs.client_key
}

/* Needed for cron_job issue */
provider "kubectl" {
  host                   = module.f5xc.utility_kubecfg_host
  cluster_ca_certificate = local.ca_certs.cluster_ca_certificate
  client_certificate     = local.ca_certs.client_certificate
  client_key             = local.ca_certs.client_key
  load_config_file       = false
}


// Is this enough to destroy?
// TODO: why is this here apart from the additional settings?
/*
provider "kubectl" {
  alias                  = "app"
  host                   = module.f5xc.app_kubecfg_host
  cluster_ca_certificate = base64decode(module.f5xc.app_kubecfg_cluster_ca)
  client_certificate     = base64decode(module.f5xc.app_kubecfg_client_cert)
  client_key             = base64decode(module.f5xc.app_kubecfg_client_key)
  load_config_file       = false
  apply_retry_count      = 10
}

provider "kubectl" {
  alias                  = "utility"
  host                   = module.f5xc.utility_kubecfg_host
  cluster_ca_certificate = local.ca_certs.cluster_ca_certificate
  client_certificate     = local.ca_certs.client_certificate
  client_key             = local.ca_certs.client_key
  load_config_file       = false
  apply_retry_count      = 10
}
*/
