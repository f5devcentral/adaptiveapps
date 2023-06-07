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
  default     = "tiered-waap"
  description = "The name for the namespace that will contain these resources."
}

variable "volterra_origin_pool" {
  type        = string
  description = "The Origin Pool that will accept traffic after it has passed through appropriate security tiers."
}

variable "tier3_domains" {
  type = list(string)
  description = "A list of low risk domains that will have essential security applied."
}

variable "tier2_domains" {
  type = list(string)
  description = "A list of medium risk domains that will have increased security applied."
}

variable "tier1_domains" {
  type = list(string)
  description = "A list of high risk domains that will have advanced security applied."
}

