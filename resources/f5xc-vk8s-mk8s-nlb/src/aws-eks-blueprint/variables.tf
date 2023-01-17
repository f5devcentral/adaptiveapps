# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of cluster"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "VPC CIDR - used demo"
  type = string
  default = ""
}

variable "aws_region" {
  description = "AWS EKS Deployment Region."
  type = string
  default = ""
}