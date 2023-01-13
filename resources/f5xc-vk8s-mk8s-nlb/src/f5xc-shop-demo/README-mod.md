## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.7.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.8.0 |
| <a name="requirement_volterra"></a> [volterra](#requirement\_volterra) | 0.11.14 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_f5xc"></a> [f5xc](#module\_f5xc) | ./module/f5xc | n/a |
| <a name="module_vk8s-app"></a> [vk8s-app](#module\_vk8s-app) | ./module/vk8s-app | n/a |
| <a name="module_vk8s-utility"></a> [vk8s-utility](#module\_vk8s-utility) | ./module/vk8s-utility | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_p12_file"></a> [api\_p12\_file](#input\_api\_p12\_file) | n/a | `string` | `"./creds/tenant.api-creds.p12"` | no |
| <a name="input_api_url"></a> [api\_url](#input\_api\_url) | n/a | `string` | `"https://tenant.ves.volterra.io/api"` | no |
| <a name="input_app_fqdn"></a> [app\_fqdn](#input\_app\_fqdn) | n/a | `string` | `"demo-app.tenant.example.com"` | no |
| <a name="input_base"></a> [base](#input\_base) | n/a | `string` | `"demo-app"` | no |
| <a name="input_bot_defense_region"></a> [bot\_defense\_region](#input\_bot\_defense\_region) | n/a | `string` | `"US"` | no |
| <a name="input_cred_expiry_days"></a> [cred\_expiry\_days](#input\_cred\_expiry\_days) | n/a | `number` | `89` | no |
| <a name="input_enable_bot_defense"></a> [enable\_bot\_defense](#input\_enable\_bot\_defense) | n/a | `bool` | `false` | no |
| <a name="input_enable_client_side_defense"></a> [enable\_client\_side\_defense](#input\_enable\_client\_side\_defense) | n/a | `bool` | `false` | no |
| <a name="input_enable_synthetic_monitors"></a> [enable\_synthetic\_monitors](#input\_enable\_synthetic\_monitors) | n/a | `bool` | `false` | no |
| <a name="input_hub_site_selector"></a> [hub\_site\_selector](#input\_hub\_site\_selector) | n/a | `list` | <pre>[<br>  "ves.io/siteName in (ves-io-dc12-ash)"<br>]</pre> | no |
| <a name="input_registry_config_json"></a> [registry\_config\_json](#input\_registry\_config\_json) | registry config data string in type kubernetes.io/dockerconfigjson | `string` | `"b64 encoded json"` | no |
| <a name="input_registry_server"></a> [registry\_server](#input\_registry\_server) | n/a | `string` | `"some_registry.example.com"` | no |
| <a name="input_spoke_site_selector"></a> [spoke\_site\_selector](#input\_spoke\_site\_selector) | n/a | `list` | <pre>[<br>  "ves.io/siteName in (ves-io-ny8-nyc, ves-io-wes-sea)"<br>]</pre> | no |
| <a name="input_utility_site_selector"></a> [utility\_site\_selector](#input\_utility\_site\_selector) | n/a | `list` | <pre>[<br>  "ves.io/siteName in (ves-io-dc12-ash)"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_url"></a> [app\_url](#output\_app\_url) | FQDN VIP to access the web app |
