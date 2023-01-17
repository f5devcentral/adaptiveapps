provider "volterra" {
  api_p12_file = "/path/to/api_credential.p12"
  url          = "https://<tenant_name>.console.ves.volterra.io/api"
  alias        = "tenancy"
}