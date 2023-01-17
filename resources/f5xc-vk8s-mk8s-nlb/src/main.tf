#---------------------------------------------------------------
# AWS EKS Blueprint
#---------------------------------------------------------------

module "aws_eks_blueprint" {
  source = "./aws-eks-blueprint/"

  cluster_name = var.cluster_name
  aws_region   = var.aws_region
  vpc_cidr     = var.vpc_cidr
}

#---------------------------------------------------------------
# F5XC Shop Demo (vK8s)
#---------------------------------------------------------------

module "f5xc_shop_demo" {
  source = "./f5xc-shop-demo/"
  # source = "github.com/f5devcentral/f5xc-shop-demo?ref=staging"

  api_url              = var.api_url
  api_p12_file         = var.api_p12_file
  base                 = var.base
  app_fqdn             = var.app_fqdn
  registry_server      = var.registry_server
  registry_config_json = var.registry_config_json
}
