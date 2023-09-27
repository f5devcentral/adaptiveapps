# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = "juiced-ce-aws"
}

variable "cluster_version" {
  description = "The Version of Kubernetes to deploy for application infrastructure"
  type        = string
  default     = "1.25"
}

variable "region" {
  description = "Name of AWS deployment region for application infrastructure"
  type        = string
  default     = "ap-southeast-2"
}

variable "vpc_cidr" {
  description = "CIDR of deployment VPC for application infrastructure"
  type        = string
  default     = "10.0.0.0/16"
}

variable "base_tag" {
  description = "Name prefix of application deployment"
  type        = string
  default     = "juiced-ce-aws"
}

variable "owner" {
  description = "Deployment owner/business unit for Application Ownership"
  type        = string
  default     = "f5-aatt"
}

variable "instance" {
  description = "Deployment EC2 instance type"
  type        = string
  default     = "t3.xlarge"
}

variable "app" {
  description = "Deployment Application"
  type        = string
  default     = "JuiceShop"
}

variable "ec2_key" {
  description = "EC2 Deployment Keypair"
  default     = "<your ec2-keypair access key>"
  type        = string
}

variable "aws_access_key" {
  type        = string
  default     = "<your aws access key>"
  description = "AWS Access Key. Programmable API access key needed for creating the site"
}

variable "aws_secret_key" {
  type        = string
  default     = "<your aws secret>"
  description = "AWS Secret Access Key. Programmable API secret access key needed for creating the site"
}

variable "site_disk_size" {
  type        = number
  description = "Disk size in GiB"
  default     = 80
}

variable "api_url" {
  description = "Tenancy API Endpoint - https://docs.cloud.f5.com/docs/how-to/volterra-automation-tools/apis"
  nullable    = false
  type        = string
}

variable "api_p12_file" {
  description = "Tenant API credentials - https://docs.cloud.f5.com/docs/how-to/volterra-automation-tools/apis#authentication"
  nullable    = false
  type        = string
}

variable "ssh_public_key" {
  type        = string
  description = "SSH Public Key"
  default     = "<your public key>"
}