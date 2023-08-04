provider "volterra" {
  api_cert = "files/certificate.cert"
  api_key  = "files/private_key.key"
  url      = var.api_url
  timeout = "120s"
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}