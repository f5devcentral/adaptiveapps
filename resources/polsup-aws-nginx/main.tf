provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

resource "random_id" "id" {
  byte_length = 2
}

locals {
  region   = var.region
  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  build = random_id.id.hex
  name  = coalesce(var.name, local.build)

  tags = {
    Owner       = var.owner
    Application = var.app
  }
}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 20)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # using the database subnet method since it allows a public route
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  tags = local.tags
}

#---------------------------------------------------------------
# F5/NGINX Resources
#---------------------------------------------------------------
module "nginx-nap" {
  source = "../modules/nginx-nap"

  prefix      = local.name
  region      = var.region
  vpc_id      = module.vpc.vpc_id
  app_subnets = module.vpc.public_subnets
  random      = local.build
  ec2_key     = var.ec2_key
  app         = "nginx-nap"
}

module "juiceshop-app" {
  source = "../modules/juiceshop"

  prefix      = local.name
  region      = var.region
  vpc_id      = module.vpc.vpc_id
  app_subnets = module.vpc.private_subnets
  random      = local.build
  ec2_key     = var.ec2_key
  app         = var.app
}

module "bastion" {
  source = "../modules/jumphost"

  prefix         = local.name
  region         = var.region
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.database_subnets
  random         = local.build
  ec2_key        = var.ec2_key
}