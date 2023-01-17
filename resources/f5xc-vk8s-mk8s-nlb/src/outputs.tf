output "f5xc_app_url" {
  description = "FQDN VIP to access the web app"
  value       = module.f5xc_shop_demo.app_url
}