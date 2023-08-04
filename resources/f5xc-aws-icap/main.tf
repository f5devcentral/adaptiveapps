provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
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
  name  = coalesce(var.base_tag, local.build)
  # var.cluster_name is for Terratest
  cluster_name = coalesce(var.cluster_name, local.name)

  tags = {
    Owner       = var.owner
    Application = var.app
  }
}

#---------------------------------------------------------------
# AWS Supporting Resources
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

module "jumphost" {
  source = "../modules/jumphost"

  prefix         = local.name
  region         = var.region
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.database_subnets
  random         = local.build
  ec2_key        = var.ec2_key
}

resource "aws_key_pair" "this" {
  key_name   = format("%s-key", local.name)
  public_key = var.ssh_public_key
}

#---------------------------------------------------------------
# F5XC Resources
#---------------------------------------------------------------
data "aws_instance" "voltmesh" {
  depends_on = [volterra_tf_params_action.apply_aws_vpc]
  filter {
    name   = "tag:Name"
    values = ["master-0"]
  }
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }
}

resource "volterra_k8s_cluster" "this" {
  name                              = local.cluster_name
  namespace                         = "system"
  no_cluster_wide_apps              = true
  use_default_cluster_role_bindings = true
  use_default_cluster_roles         = true
  use_default_psp                   = true
}

resource "volterra_cloud_credentials" "aws" {
  name        = format("%s-cred", local.name)
  description = format("AWS credential will be used to create site %s", local.name)
  namespace   = "system"
  aws_secret_key {
    access_key = var.aws_access_key
    secret_key {
      clear_secret_info {
        url = "string:///${base64encode(var.aws_secret_key)}"
      }
    }
  }
}

resource "volterra_aws_vpc_site" "this" {
  name       = local.cluster_name
  namespace  = "system"
  aws_region = local.region
  aws_cred {
    name      = volterra_cloud_credentials.aws.name
    namespace = "system"
  }
  vpc {
    vpc_id = module.vpc.vpc_id
  }
  disk_size     = var.site_disk_size
  instance_type = var.instance
  ssh_key       = aws_key_pair.this.public_key

  voltstack_cluster {
    aws_certified_hw = "aws-byol-voltstack-combo"
    az_nodes {
      aws_az_name = module.vpc.azs[0]
      local_subnet {
        existing_subnet_id = module.vpc.public_subnets[0]
      }
    }
    k8s_cluster {
      name      = local.cluster_name
      namespace = "system"
    }
  }
}

resource "null_resource" "wait_for_aws_mns" {
  triggers = {
    depends = volterra_aws_vpc_site.this.id
  }
}

resource "volterra_tf_params_action" "apply_aws_vpc" {
  depends_on       = [null_resource.wait_for_aws_mns]
  site_name        = local.cluster_name
  site_kind        = "aws_vpc_site"
  action           = "apply"
  wait_for_action  = true
  ignore_on_update = true
}