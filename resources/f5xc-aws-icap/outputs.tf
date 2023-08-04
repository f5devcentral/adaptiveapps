output "vpc_private_subnet_cidr" {
  description = "VPC private subnet CIDR"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "vpc_public_subnet_cidr" {
  description = "VPC public subnet CIDR"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "vpc_management_subnet_cidr" {
  description = "VPC Management subnet CIDR"
  value = module.vpc.database_subnets_cidr_blocks
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = module.vpc.vpc_cidr_block
}

# Region used for Terratest
output "region" {
  description = "AWS region"
  value       = local.region
}

output "jumpbox_public_dns" {
  description = "Public DNS address of Jumpbox"
  value       = module.jumphost.public_dns
}