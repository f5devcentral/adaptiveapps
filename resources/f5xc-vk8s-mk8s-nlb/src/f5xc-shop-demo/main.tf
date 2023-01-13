locals {
  registry = {
    server = var.registry_server
    config_json = var.registry_config_json
  }
}

module "f5xc" {
  source = "./module/f5xc"

  api_url                    = var.api_url
  api_p12_file               = "${path.module}/../creds/${var.api_p12_file}"
  base                       = var.base
  app_fqdn                   = var.app_fqdn
  spoke_site_selector        = var.spoke_site_selector
  hub_site_selector          = var.hub_site_selector
  utility_site_selector      = var.utility_site_selector
  cred_expiry_days           = var.cred_expiry_days
  enable_bot_defense         = var.enable_bot_defense
  bot_defense_region         = var.bot_defense_region
  enable_synthetic_monitors  = var.enable_synthetic_monitors
  enable_client_side_defense = var.enable_client_side_defense
}

// Build the front-end application
module "vk8s-app" {
  source = "./module/vk8s-app"

  providers = {
    kubernetes = kubernetes.app 
   }

  namespace     = module.f5xc.app_namespace
  spoke_vsite   = module.f5xc.spoke_vsite
  hub_vsite     = module.f5xc.hub_vsite

  enable_client_side_defense  = var.enable_client_side_defense
  registry_server             = local.registry.server
  registry_config_json        = local.registry.config_json
}

// Build Utility/Hub sitss
module "vk8s-utility" {
  source = "./module/vk8s-utility"

  providers = {
    kubernetes = kubernetes.utility 
   }

  namespace       = module.f5xc.utility_namespace
  vsite           = module.f5xc.utility_vsite
  app_namespace   = module.f5xc.app_namespace
  target_url      = module.f5xc.app_url
  app_kubecfg     = module.f5xc.app_kubecfg

  registry_server             = local.registry.server
  registry_config_json        = local.registry.config_json
}
