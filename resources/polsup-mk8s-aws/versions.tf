terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72"
    }
    volterra = {
      source = "volterraedge/volterra"
      # version = "0.7.1"
      version = "0.11.24"
    }
  }

  # ##  Used for end-to-end testing on project; update to suit your needs
  # backend "s3" {
  #   bucket = "terraform-ssp-github-actions-state"
  #   region = "us-west-2"
  #   key    = "e2e/eks-cluster-with-new-vpc/terraform.tfstate"
  # }
}