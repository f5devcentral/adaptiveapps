variable "api_url" {
  description = "Tenancy API Endpoint - https://docs.cloud.f5.com/docs/how-to/volterra-automation-tools/apis"
  default     = "https://tenant.ves.volterra.io/api"
}

variable "api_p12_file" {
  description = "Tenant API credentials - https://docs.cloud.f5.com/docs/how-to/volterra-automation-tools/apis#authentication"
  default     = "./creds/tenant.api-creds.p12"
}

variable "base" {
  description = "Deployment base prefix tag"
  default     = "demo-app"
}


variable "app_fqdn" {
  description = "Application FrontEnd HTTP FQDN"
  default     = "demo-app.tenant.example.com"
}
// TODO: variables for AUS region
/*
variable "spoke_site_selector" {
  description = "FrontEnd Spoke sites"
  default = ["ves.io/siteName in (ves-io-sy5-syd, ves-io-me1-mel)"]
}

variable "hub_site_selector" {
  description = "Hub site"
  default = ["ves.io/siteName in (ves-io-sy5-syd)"]
}

variable "utility_site_selector" {
  description = "Utility site"
  default = ["ves.io/siteName in (ves-io-sy5-syd)"]
}
*/
// Original
variable "spoke_site_selector" {
  description = "FrontEnd Spoke sites"
  default = ["ves.io/siteName in (ves-io-ny8-nyc, ves-io-wes-sea)"]
}

variable "hub_site_selector" {
  description = "Hub site"
  default = ["ves.io/siteName in (ves-io-dc12-ash)"]
}

variable "utility_site_selector" {
  description = "Utility site"
  default = ["ves.io/siteName in (ves-io-dc12-ash)"]
}

variable "cred_expiry_days" {
  description = "Credential life-cycle (days)"
  default     = 89
}

variable "registry_server" {
  description = "Container Registry repo"
  default     = "some_registry.example.com"
}

variable "registry_config_json" {
  description = "registry config data string in type kubernetes.io/dockerconfigjson"
  default     = "b64 encoded json"
}

/*
Optional Functionality
*/
variable "enable_bot_defense" {
  description = "Enable bot defense"
  default     = false
}

variable "bot_defense_region" {
  description = "botdefense region"
  default     = "US"
}

variable "enable_synthetic_monitors" {
  description = "Enable Synthetic monitoring"
  default     = false
}

variable "enable_client_side_defense" {
  description = "Enable client side defenses"
  default     = false
}