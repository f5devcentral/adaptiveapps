#---------------------------------------------------------------
# AWS EKS Blueprint
#---------------------------------------------------------------

# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = "aatt-eks"
}

variable "vpc_cidr" {
  description = "VPC CIDR - used demo"
  type = string
  default = "10.0.0.0/16"
}

variable "aws_region" {
  description = "AWS EKS Deployment Region."
  type = string
  default = "us-east-1"
}

#---------------------------------------------------------------
# F5XC Shop Demo (vK8s)
#---------------------------------------------------------------

variable "api_url" {
  description = "F5XC Tenancy API endpoint"
  type = string
  default = ""
}

variable "api_p12_file" {
  description = "P!2 bundle file for F5XC API access"
  type = string
  default = ""
}

variable "base" {
  description = "Application base name"
  type = string
  default = ""
}

variable "app_fqdn" {
  description = "FQDN used for application services stack"
  type = string
  default = ""
}

variable "registry_server" {
  description = "Container Image Registry server/repo"
  type = string
  default = ""
}

variable "registry_config_json" {
  default     = ""
  description = "registry config data string in type kubernetes.io/dockerconfigjson"
  type = string
}