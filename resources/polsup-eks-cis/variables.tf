# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = "polsup-cis"
}

variable "cluster_version" {
  description = "The Version of Kubernetes to deploy"
  type        = string
  default     = "1.25"
}

variable "region" {
  description = "Name of AWS deployment region"
  type        = string
  default     = "ap-southeast-2"
}

variable "vpc_cidr" {
  description = "CIDR of deployment VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "name" {
  description = "Name prefix of deployment"
  type        = string
  default     = "polsup-cis"
}

variable "owner" {
  description = "Deployment owner"
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
  default     = "OWASP JuiceShop"
}

variable "ec2_key" {
  description = "EC2 Deployment Keypair"
  type        = string
  default     = "<your ec2-keypair access key>"
}

variable "f5_username" {
  description = "User name for the BIG-IP (Note: currently not used. Defaults to 'admin' based on AMI"
  type        = string
  default     = "admin"
}

variable "f5_password" {
  description = "BIG-IP Password or Secret ARN (value should be ARN of secret when aws_secretmanager_auth = true, ex. arn:aws:secretsmanager:us-west-2:1234:secret:bigip-secret-abcd)"
  type        = string
  default     = "Default12345!"
}
