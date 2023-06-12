variable "volterra_url" {
  nullable    = true
  type        = string
  description = "Tenant API url file path. This can also be sourced from VOLT_API_URL env variable."
}

variable "volterra_p12_file" {
  nullable    = true
  type        = string
  description = "API credential p12 file path. This can also be sourced from VOLT_API_P12_FILE env variable. The password for the p12 file must be passed as the environment variable VES_P12_PASSWORD."
}

variable "volterra_namespace_name" {
  type        = string
  default     = "data-center"
  description = "The name for the namespace that will contain these resources."
}

variable "volterra_site_name" {
  type        = string
  default     = "data-center-site"
  description = "The name of the generated App Stack site."
}

variable "volterra_master_hostname" {
  type        = string
  default     = "master-0"
  description = "The hostname of the F5 Distributed Cloud Node."
}

variable "volterra_certified_hardware" {
  type        = string
  default     = "vmware-voltstack-combo"
  description = "Name for generic server certified hardware to form the App Stack site."
}
