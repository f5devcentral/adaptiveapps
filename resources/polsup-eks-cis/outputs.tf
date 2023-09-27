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
  value       = module.vpc.database_subnets_cidr_blocks
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = module.vpc.vpc_cidr_block
}

output "eks_cluster_name" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_name
}
/*
output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks.configure_kubectl
}
*/
# Region used for Terratest
output "region" {
  description = "AWS region"
  value       = local.region
}

output "jumpbox_public_dns" {
  description = "Public DNS address of Jumpbox"
  value       = module.bastion.public_dns[0]
}

output "f5vm01_mgmt_private_ip" {
  description = "f5vm01 management private IP address"
  value       = module.big-ip.f5vm01_mgmt_private_ip
}

output "f5vm01_mgmt_public_ip" {
  description = "f5vm01 management public IP address"
  value       = module.big-ip.f5vm01_mgmt_public_ip
}

output "f5vm01_mgmt_pip_url" {
  description = "f5vm01 management public URL"
  value       = "https://${module.big-ip.f5vm01_mgmt_public_ip}:8443"
}